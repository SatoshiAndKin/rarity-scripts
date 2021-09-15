import logging
import time

import arrow
import brownie
import click
import click_log
import lazy_load

from rarity.gas_strategy import MinimumGasStrategy

logger = logging.getLogger("argobytes")


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
    except Exception as e:
        # we are inside `brownie run` and we don't want it to exit with an ugly error
        if e.exit_code != 0:
            raise


@click.group()
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
    from decimal import Decimal
    from hexbytes import HexBytes
    import eth_abi
    import eth_utils
    import IPython

    extra_locals = {
        "account": ctx.obj["account"],
        "brownie": brownie,
        "chain": brownie.chain,
        "Contract": brownie.Contract,
        "Decimal": Decimal,
        "eth_abi": eth_abi,
        "eth_utils": eth_utils,
        "gas_strat": ctx.obj["gas_strat"],
        "HexBytes": HexBytes,
        "tx_history": brownie.network.history,
        "web3": brownie.web3,
    }

    IPython.start_ipython(argv=[], user_ns=extra_locals)
