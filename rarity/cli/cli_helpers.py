import logging
import functools

import brownie
import eth_abi
import eth_utils
from decimal import Decimal
from hexbytes import HexBytes
from lazy_load import lazy_func


# TODO: we might need to move this so the cli functions can import it
logger = logging.getLogger("rarity")


def common_helpers(click_ctx):
    return {
        "account": click_ctx.obj["account"],
        "brownie": brownie,
        "chain": brownie.chain,
        "Contract": brownie.Contract,
        "Decimal": Decimal,
        "eth_abi": eth_abi,
        "eth_utils": eth_utils,
        "gas_strat": click_ctx.obj["gas_strat"],
        "HexBytes": HexBytes,
        "logger": logger,
        "tx_history": brownie.network.history,
        "web3": brownie.web3,
    }


def _lazy_account(account_name, password_name):
    print(f"Loading account {account_name}...")

    # TODO: prompt password here

    if password_name:
        with open(password_name) as f:
            password = f.read()
    else:
        # i wanted to use click options for the password, but brownie will prompt
        # we also want to keep this lazy
        password = None

    account = brownie.accounts.load(account_name, password=password)

    print(f"\nHello, {account_name}!")

    return account


lazy_account = lazy_func(_lazy_account)
