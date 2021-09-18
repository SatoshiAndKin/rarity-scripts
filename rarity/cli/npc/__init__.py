import click

from rarity.cli import rarity_cli


@rarity_cli.group()
def npc():
    """Manage Non-player characters."""


@npc.command()
@click.pass_context
def summon(ctx):
    ctx.obj["setup_gas_strat"]()

    raise NotImplementedError
