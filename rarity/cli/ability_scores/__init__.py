import click

from rarity.cli import rarity_cli


@rarity_cli.group()
def ability_scores():
    """Point buy calculations."""


@ability_scores.command()
def all():
    import json
    from rarity.ability_scores import all_attribute_permutations

    print(json.dumps(all_attribute_permutations))


@ability_scores.command()
@click.argument("class_id", type=click.IntRange(1, 11))
def good_random_array(class_id):
    from rarity.ability_scores import get_good_random_scores

    print(get_good_random_scores(class_id))
