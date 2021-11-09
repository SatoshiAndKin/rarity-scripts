import arrow
import brownie
import click
from brownie._config import CONFIG

from rarity.gas_strategy import setup_automatic_gas

from .cli_helpers import common_helpers, lazy_account


def main(*args):
    """Run the click app."""

    # TODO: https://github.com/eth-brownie/brownie/issues/1239
    if "multicall2" not in CONFIG.active_network:
        CONFIG.active_network[
            "multicall2"
        ] = "0xBAD2B082e2212DE4B065F636CA4e5e0717623d18"

    try:
        # https://click.palletsprojects.com/en/8.0.x/exceptions/#what-if-i-don-t-want-that
        ctx = rarity_cli.make_context(
            "brownie run rarity main",
            list(args),
            auto_envvar_prefix="RARITY",
            help_option_names=["/h", "/help"],
        )

        with ctx:
            rarity_cli.invoke(ctx)
    except click.exceptions.Exit as e:
        # we are inside `brownie run` and we don't want it to exit with an ugly error
        # TODO: catch abort, too?
        if e.exit_code != 0:
            raise


@click.group()
@click.option("/account", help="The brownie account to load")
# TODO: click type for secure readable file
@click.option(
    "/passfile", help="DANGER! File that contains the account password. DANGER!"
)
# TODO: option to load password from a file
@click.option(
    "/gas-time",
    default=60,
    help="how often to check if gas price needs to be increased",
)
@click.option(
    "/gas-extra",
    default="1 gwei",
    help="how much more than the minimum gas price to pay",
)
@click.pass_context
def rarity_cli(ctx, account, gas_time, gas_extra, passfile):
    """Command line interface for Rarity."""
    assert brownie.chain.id in [250, 31337], "not Fantom or forked network!"

    print("\nConnected to", brownie.web3.provider.endpoint_uri)

    # do this lazily because not all functions will use the account
    brownie.accounts.default = lazy_account(account, passfile)


@rarity_cli.command()
@click.pass_context
def console(ctx):
    """Open an interactive console."""
    import IPython

    setup_automatic_gas()

    IPython.start_ipython(argv=[], user_ns=common_helpers(ctx))


@rarity_cli.command()
@click.argument("python_code", type=str)
@click.pass_context
def run(ctx, python_code):
    """Exec arbitrary (and hopefully audited!) python code. Be careful with this!"""

    setup_automatic_gas()

    print(eval(python_code, {}, common_helpers(ctx)))


@rarity_cli.command()
@click.argument("python_file", type=click.File(mode="r"))
@click.pass_context
def run_file(ctx, python_file):
    """Exec arbitrary (and hopefully audited!) python files. Be careful with this!"""

    setup_automatic_gas()

    print(eval(python_file.read(), {}, common_helpers(ctx)))
