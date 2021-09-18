import click
from rarity.cli import rarity_cli


@rarity_cli.group()
def dungeon():
    """Manage a dungeon."""


@dungeon.command()
@click.pass_context
def create(ctx):
    """Create an adventure."""
    ctx.obj["setup_gas_strat"]()

    raise NotImplementedError


@dungeon.command()
@click.pass_context
def adventure(ctx):
    """Enter an adventure."""
    ctx.obj["setup_gas_strat"]()

    raise NotImplementedError


@dungeon.command()
@click.pass_context
def play(ctx):
    """Play the current adventure."""
    ctx.obj["setup_gas_strat"]()

    raise NotImplementedError
