from rarity.cli import rarity_cli

@rarity_cli.group()
def guild():
    """Manage a Guild."""


@guild.command()
def found():
    raise NotImplementedError

