import click
from rarity.cli import rarity_cli


@rarity_cli.group()
def dungeon():
    """Manage a dungeon."""


@dungeon.command()
@click.pass_context
def create(ctx):
    ctx.obj["setup_gas_strat"]()

    raise NotImplementedError
