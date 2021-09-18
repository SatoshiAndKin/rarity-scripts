import click

from rarity.cli import rarity_cli


@rarity_cli.group()
def player():
    """Manage player characters."""


@player.command()
@click.pass_context
def summon(ctx):
    """Summon a new player character."""
    from .summon import summon

    summon(ctx)
