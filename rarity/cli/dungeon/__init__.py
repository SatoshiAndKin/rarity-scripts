import click
from rarity.cli import rarity_cli


@rarity_cli.group()
def dungeon():
    """Manage a dungeon."""


@dungeon.command()
@click.pass_context
def create(ctx):
    """Create an adventure."""
    setup_automatic_gas()

    raise NotImplementedError


@dungeon.command()
@click.pass_context
def scout(ctx):
    """Enter an adventure."""
    setup_automatic_gas()

    raise NotImplementedError


@dungeon.command()
@click.pass_context
def adventure(ctx):
    """Enter an adventure."""
    setup_automatic_gas()

    raise NotImplementedError


@dungeon.command()
@click.pass_context
def play(ctx):
    """Play the current adventure."""
    setup_automatic_gas()

    raise NotImplementedError
