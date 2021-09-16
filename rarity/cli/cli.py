import arrow
import brownie
import click
import click_log

from rarity.gas_strategy import MinimumGasStrategy

from .cli_helpers import logger, common_helpers


def main(*args):
    """Run the click app."""
    click_log.basic_config(logger)

    try:
        # https://click.palletsprojects.com/en/8.0.x/exceptions/#what-if-i-don-t-want-that
        ctx = rarity_cli.make_context(
            "brownie run rarity main",
            list(args),
            auto_envvar_prefix="RARITY",
            help_option_names=['/h', '/help'],
        )

        with ctx:
            rarity_cli.invoke(ctx)
    except click.exceptions.Exit as e:
        # we are inside `brownie run` and we don't want it to exit with an ugly error
        # TODO: catch abort, too?
        if e.exit_code != 0:
            raise


@click.group()
@click_log.simple_verbosity_option(logger)
@click.option("/account", prompt=True)
@click.option("/password", prompt=True, hide_input=True)
@click.option("/gas-time", default=60)
@click.option("/gas-extra", default="1 gwei")
@click.pass_context
def rarity_cli(ctx, account, gas_time, gas_extra, password):
    """Command line interface for Rarity."""
    assert brownie.chain.id == 250, "not Fantom network!"

    # TODO: wait to load this
    brownie_account = brownie.accounts.load(account, password=password)

    print(f"Hello, {brownie_account}!\n")

    print("\nConnected to", brownie.web3.provider.endpoint_uri)

    last_block = brownie.chain[-1]
    print("Last block:", last_block.number, arrow.get(last_block.timestamp).humanize(), "\n")

    gas_strat = MinimumGasStrategy(gas_time, gas_extra)

    print(gas_strat, "\n")
    brownie.network.gas_price(gas_strat)

    ctx.ensure_object(dict)

    ctx.obj.update({
        "account": account,
        "gas_strat": gas_strat,
    })


@rarity_cli.command()
@click.pass_context
def console(ctx):
    """Open an interactive console."""
    import IPython

    IPython.start_ipython(argv=[], user_ns=common_helpers(ctx))


@rarity_cli.command()
@click.argument("python_code", type=str)
@click.pass_context
def run(ctx, python_code):
    """Exec arbitrary (and hopefully audited!) python code. Be careful with this!"""
    eval(python_code, {}, common_helpers(ctx))


@rarity_cli.command()
@click.argument("python_file", type=click.File(mode="r"))
@click.pass_context
def run_file(ctx, python_file):
    """Exec arbitrary (and hopefully audited!) python files. Be careful with this!"""
    eval(python_file.read(), {}, common_helpers(ctx))
