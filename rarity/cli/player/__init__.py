from rarity.cli import rarity_cli

@rarity_cli.group()
def player():
    """Manage player characters."""


@player.command()
def summon():
    """Summon a new player character."""
    from .summon import summon
    summon()
