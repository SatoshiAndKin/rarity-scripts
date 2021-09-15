import logging

import click
import click_log
from brownie import accounts, chain
from brownie.network import gas_price

logger = logging.getLogger("argobytes")


def get_summoners():
    raise NotImplementedError


@click.command()
@click.option("--account", prompt=True)
@click.pass_context
def rarity_cli(ctx, account):
    """Command line interface for Rarity."""
    assert chain.id == 250, "not Fantom network!"

    # TODO: open account
    account = accounts.load(account)

    gas_strat = NotImplemented

    print(gas_strat)
    gas_price(gas_strat)

    ctx.ensure_object(dict)

    ctx.update({
        "account": account,
        "gas_strat": gas_strat,
    })



def main():
    """Run the click app."""
    click_log.basic_config(logger)

    rarity_cli.main(
        # TODO: build args
        [],
        auto_envvar_prefix="RARITY",
        standalone_mode=False,
    )
