import click

from rarity.cli import rarity_cli


@rarity_cli.group()
def ability_scores():
    """Point buy calculations."""


@ability_scores.command()
def all():
    from .ability_scores import all_attribute_permutations
    import json

    print(json.dumps(all_attribute_permutations))
