import click

from rarity.cli import rarity_cli


@rarity_cli.group()
def npc():
    """Manage non-player characters."""


@npc.command()
@click.pass_context
def summon(ctx):
    """Summon a group of non-player characters."""
    ctx.obj["setup_gas_strat"]()

    raise NotImplementedError
