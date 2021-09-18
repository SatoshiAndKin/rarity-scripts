from rarity.cli import rarity_cli


@rarity_cli.group()
def npc():
    """Manage Non-player characters."""


@npc.command()
def summon():
    raise NotImplementedError
