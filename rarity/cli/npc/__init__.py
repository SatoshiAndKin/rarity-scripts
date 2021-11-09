import click

from rarity.cli import rarity_cli
from rarity.gas_strategy import setup_automatic_gas


@rarity_cli.group()
def npc():
    """Manage non-player characters."""


@npc.command()
@click.pass_context
def summon(ctx):
    """Summon a group of non-player characters."""
    setup_automatic_gas()

    raise NotImplementedError
