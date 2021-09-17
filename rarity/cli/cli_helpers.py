import click
import logging

import brownie
import eth_abi
import eth_utils
from decimal import Decimal
from hexbytes import HexBytes
from lazy_load import lazy_func

from rarity import contracts


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
        "RARITY": contracts.RARITY,
        "RARITY_ATTRIBUTES": contracts.RARITY_ATTRIBUTES,
        "RARITY_CRAFT_1": contracts.RARITY_CRAFT_1,
        "RARITY_CRAFTING_1": contracts.RARITY_CRAFTING_1,
        "RARITY_GOLD": contracts.RARITY_GOLD,
        "RARITY_SKILLS": contracts.RARITY_SKILLS,
        "RARITY_CODEX_RANDOM": contracts.RARITY_CODEX_RANDOM,
        "RARITY_CODEX_SKILLS": contracts.RARITY_CODEX_SKILLS,
        "RARITY_CODEX_CLASS_SKILLS": contracts.RARITY_CODEX_CLASS_SKILLS,
        "RARITY_CODEX_FEATS_1": contracts.RARITY_CODEX_FEATS_1,
        "RARITY_CODEX_ITEMS_GOODS": contracts.RARITY_CODEX_ITEMS_GOODS,
        "RARITY_CODEX_ITEMS_ARMOR": contracts.RARITY_CODEX_ITEMS_ARMOR,
        "RARITY_CODEX_ITEMS_WEAPONS": contracts.RARITY_CODEX_ITEMS_WEAPONS,
        "RARITY_ACTION_V2": contracts.RARITY_ACTION_V2,
    }


def _lazy_account(account_name, password_name):
    if not account_name:
        account_name = click.prompt("Account")

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

    print(f"\nHello, {account}!")

    return account


lazy_account = lazy_func(_lazy_account)
