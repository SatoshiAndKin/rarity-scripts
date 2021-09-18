import click

from rarity.cli import rarity_cli


@rarity_cli.group()
def guild():
    """Manage a Guild."""


@guild.command()
@click.pass_context
def found(ctx):
    ctx.obj["setup_gas_strat"]()

    raise NotImplementedError


@guild.command()
@click.pass_context
def summon(ctx):
    ctx.obj["setup_gas_strat"]()

    raise NotImplementedError
