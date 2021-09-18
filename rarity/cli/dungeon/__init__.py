from rarity.cli import rarity_cli


@rarity_cli.group()
def dungeon():
    """Manage a dungeon."""


@dungeon.command()
def create():
    raise NotImplementedError
