import click

from rarity.cli import rarity_cli


@rarity_cli.group()
def accounts():
    """Manage brownie's accounts."""


@accounts.command()
@click.argument("account-name", type=str)
@click.option("/mnemonic", prompt=True, hide_input=True)
@click.option("/mnemonic-passphrase", prompt=True, default="", hide_input=True)
@click.option("/encryption-passphrase", prompt=True, required=True, hide_input=True)
@click.option("/offset", prompt=True, default=0, show_default=True)
@click.option("/save-pass;/no-save-pass", default=False)
def from_mnemonic(account_name, mnemonic, mnemonic_passphrase, encryption_passphrase, offset, save_pass):
    """Create a brownie account from an existing mnemonic."""
    from .mnemonic import account_from_mnemonic

    account_from_mnemonic(mnemonic, mnemonic_passphrase, offset, account_name, encryption_passphrase, save_pass=save_pass)


# TODO: command to make a random account with a cool vanity address (but then we have to make sure backups are handled properly)
