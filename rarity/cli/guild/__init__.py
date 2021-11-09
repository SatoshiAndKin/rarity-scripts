import click

from rarity.cli import rarity_cli
from rarity.gas_strategy import setup_automatic_gas


@rarity_cli.group()
def guild():
    """Manage a Guild."""


@guild.command()
@click.pass_context
def found(ctx):
    """Found a new guild."""
    setup_automatic_gas()

    raise NotImplementedError


@guild.command()
@click.pass_context
def summon(ctx):
    """Create a summoner for your guild."""
    setup_automatic_gas()

    raise NotImplementedError
