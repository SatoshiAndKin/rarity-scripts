import logging

import brownie
import eth_abi
import eth_utils
from decimal import Decimal
from hexbytes import HexBytes


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
