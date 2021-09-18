"""
A [brownie script](https://eth-brownie.readthedocs.io/en/stable/interaction.html#running-scripts)
that forwards everything to the [click application](https://click.palletsprojects.com/) in rarity/cli/cli.py
"""
from rarity import cli


def main(*args):
    cli.main(*args)
