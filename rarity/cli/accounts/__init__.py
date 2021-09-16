import click

from rarity.cli import rarity_cli

@rarity_cli.group()
def accounts():
    """Manage brownie's accounts."""


@accounts.command()
@click.argument("output", type=str)
@click.option("--mnemonic", prompt=True, hide_input=True)
@click.option("--mnemonic-passphrase", prompt=True, default="", hide_input=True)
@click.option("--encryption-passphrase", prompt=True, required=True, hide_input=True)
@click.option("--offset", prompt=True, default=0, show_default=True)
@click.option("--save-pass/--no-save-pass", default=False)
def from_mnemonic(output, mnemonic, mnemonic_passphrase, encryption_passphrase, offset, save_pass):
    """Create a brownie account from a mnemonic."""
    from .mnemonic import account_from_mnemonic

    account_from_mnemonic(mnemonic, mnemonic_passphrase, offset, output, encryption_passphrase, save_pass=save_pass)
