"""
Recommended gas price strategy.
"""
import os
import time
from decimal import Decimal
from typing import Generator

from brownie import chain, network, web3
from brownie.convert import Fixed, Wei
from brownie.network.gas.bases import BlockGasStrategy

from .web3_helpers import is_forked_network


class RecommendedGasStrategy(BlockGasStrategy):
    """
    Gas strategy for paying the recommended gas. This will be very slow on congested chains.
    TODO: i'd prefer to use a gas-now style strategy, but these chains don't have the graphql rpc necessary to do that
    """

    def __init__(
        self,
        time_duration=60,
        extra="1 gwei",
        max_gas_price=None,
        scale_recommended=0.8,
    ):
        if chain.id == 137 and is_forked_network():
            # TODO: something is broken with ganache+polygon+parsing blocks
            # their error message sends us here:
            # http://web3py.readthedocs.io/en/stable/middleware.html#geth-style-proof-of-authority
            # TODO: try hardhat instead
            block_time = 2.4
        else:
            # this isn't perfect, but it works well enough
            block_time = (time.time() - chain[-1000].timestamp) / 1000

        block_duration = int(round(time_duration / block_time, 0))
        if not block_duration:
            block_duration = 1

        super().__init__(block_duration)

        self.block_time = block_time * block_duration
        self.extra = Fixed(extra)
        self.max_gas_price = max_gas_price

        print(
            "Scaling recommended gas by",
            scale_recommended,
            "and adding",
            self.extra,
            "wei",
        )
        self.scale_recommended = scale_recommended

    def __str__(self) -> str:
        pretty_gas_price = next(self.get_gas_price()) / Fixed("1e9")
        return f"RecommendedGasStrategy recommends {pretty_gas_price} gwei checking after ~{self.block_time:.0f} seconds ({self.duration} blocks)"


    def check_recommendation(self):
        if not self.max_gas_price:
            return

        new_recommendation = self.get_recommended_gas_price()

        if self.max_gas_price < new_recommendation:
            raise ValueError(f"Recommended gas ({new_recommendation/Decimal(1e9)} gwei) greater than allowed maximum ({self.max_gas_price/Decimal(1e9)} gwei)!")

    def get_recommended_gas_price(self):
        # TODO: on fantom, i actually want the minimum! I don't know how to get that. it doesn't seem exposed
        # TODO: maybe just start low and have brownie catch "transaction underpriced"
        # TODO: if forked network, ganache always says 16. get the upstream instead
        return int(web3.eth.gasPrice * self.scale_recommended) + self.extra

    def get_gas_price(self) -> Generator[Wei, None, None]:
        last_gas_price = self.get_recommended_gas_price()

        yield last_gas_price

        while True:
            min_price = self.get_recommended_gas_price()

            # a normal gas strategy would increment by at least 10%
            # but we want to stay at the floor price. on fantom, that should still get picked up somewhat quickly
            # last_gas_price = last_gas_price * 1.101

            last_gas_price = min(min_price, last_gas_price)

            if self.max_gas_price:
                last_gas_price = min(self.max_gas_price, last_gas_price)

            # brownie won't re-broadcast if <10% from the previous price
            yield last_gas_price


def setup_automatic_gas(max_gas_price=None) -> Fixed:
    # we don't want to base the max off what the node told us. we don't want absurdly high prices to surprie us!
    if max_gas_price is None:
        max_gas_price = os.environ.get("MAX_GAS", "300 gwei")
    max_gas_price = Fixed(max_gas_price)

    # reverting out of gas is always terribly sad
    network.main.gas_buffer(1.5)

    # use estimateGas everywhere (even forked networks because we use unlocked accounts there with small ETH balances)
    network.main.gas_limit("auto")

    if is_forked_network():
        # TODO: how should we do gas on a forked network
        # TODO: i'd like the real price on mainnet to come in,
        print(f"dev network. setting gas to {max_gas_price/Decimal(1e9)} gwei")
        network.gas_price(max_gas_price)

        # clear the other gas price settings
        network.max_fee(None)
        network.priority_fee(None)
    else:
        # TODO: if the current recommended is > max, exit now


        if chain.id == 250:
            scale_recommended = 1.01
        else:
            scale_recommended = 0.8

        # TODO: let the user customize these
        gas_strat = RecommendedGasStrategy(
            time_duration=30,
            extra="1 gwei",
            max_gas_price=max_gas_price,
            scale_recommended=scale_recommended,
        )

        print(gas_strat)
        # if the current recommended is > max, exit now
        gas_strat.check_recommendation()

        if chain.id == 1:
            # if the chain supports EIP-1559, instead of gas_start, use priority fee

            print(
                f"REAL network with EIP-1559. setting priority_fee to 1.4 gwei and max to {int(max_gas_price)/int(1e9):_} gwei"
            )

            # TODO: if using eden, we want the minimum priority fee included in the last few blocks
            network.priority_fee("1.4 gwei")

            # TODO: if this is way way over the current recommended, pick something lower?
            network.max_fee(max_gas_price)

            # clear the other gas price settings
            network.gas_price(None)
        else:
            # the chain does not support EIP-1559. use whatever the node gives us
            print(
                f"REAL network without EIP-1559. setting max to {int(max_gas_price)/int(1e9):_} gwei"
            )

            network.gas_price(gas_strat)

            # clear the eip-1559 settings
            network.priority_fee(None)
            network.max_fee(None)

    return max_gas_price
