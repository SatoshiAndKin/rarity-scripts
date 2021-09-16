# helper to turn a mnemonic (like from metamask) into a brownie account
"""
Take a mnemonic, passphrase, and HD path and output a hex-encoded private key
Harware wallets are great, but sometimes you need automation.
"""
from pathlib import Path

import brownie
import click


def account_from_mnemonic(mnemonic, mnemonic_passphrase, offset, output, encryption_passphrase, save_pass=False):
    # TODO: allow creating more than one at a time. but then how should we handle key-name?
    account = brownie.accounts.from_mnemonic(mnemonic, count=1, offset=offset, passphrase=mnemonic_passphrase)

    click.confirm(f"Save {account} @ {output}?", abort=True)

    if save_pass:
        pass_filename = f"{output}.pass"

        accounts = Path.home() / ".brownie" / "accounts"

        if not accounts.exists():
            accounts.mkdir()

        pass_dir = accounts / "pass"
        if pass_dir.exists():
            # TODO: only do this if not already 700?
            pass_dir.chmod(0o700)
        else:
            pass_dir.mkdir(mode=0o700)

        pass_file = pass_dir / pass_filename

        pass_file.touch(mode=0o600, exist_ok=False)

        with pass_file.open("w") as f:
            f.write(encryption_passphrase)

        pass_file.chmod(0o400)

    account.save(output, password=encryption_passphrase)

    return account
