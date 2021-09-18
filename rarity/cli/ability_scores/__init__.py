import click

from rarity.cli import rarity_cli


@rarity_cli.group()
def ability_scores():
    """Point buy calculations."""
    raise NotImplemented
