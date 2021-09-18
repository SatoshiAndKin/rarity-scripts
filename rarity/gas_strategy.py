"""
Minimum gas price strategy.

"""
import time
from typing import Generator

from brownie import chain, web3
from brownie.convert import Wei
from brownie.network.gas.bases import BlockGasStrategy


def is_forked_network() -> bool:
    # TODO: copy this from argobytes
    return False


class MinimumGasStrategy(BlockGasStrategy):
    """
    Gas strategy for paying minimum possible gas. This will be very slow on congested chains.

    TODO: i'd prefer to use a gas-now style strategy, but these chains don't have the graphql rpc necessary to do that
    """

    def __init__(self, time_duration=60, extra="1 gwei"):
        if chain.id == 137 and is_forked_network():
            # TODO: something is broken with ganache+polygon+parsing blocks
            # their error message sends us here:
            # http://web3py.readthedocs.io/en/stable/middleware.html#geth-style-proof-of-authority
            # TODO: maybe try hardhat instead
            block_time = 2.4
        else:
            block_time = (time.time() - chain[-1000].timestamp) / 1000

        block_duration = int(round(time_duration / block_time, 0))
        if not block_duration:
            block_duration = 1

        super().__init__(block_duration)

        self.block_time = block_time * block_duration
        self.extra = extra

    def __str__(self) -> str:
        gas_price = next(self.get_gas_price())
        return f"MinimumGasStrategy currently recommends {gas_price/1e9:_} gwei checking after ~{self.block_time:.0f} seconds ({self.duration} blocks)"

    def get_minimum_gas_price(self):
        # TODO: this is NOT the actual minimum! I don't know what is. it doesn't seem exposed
        # TODO: maybe just start real low and have brownie catch "transaction underpriced"
        return web3.eth.gasPrice * 0.8

    def get_gas_price(self) -> Generator[Wei, None, None]:
        last_gas_price = self.get_minimum_gas_price()

        yield last_gas_price

        while True:
            min_price = self.get_minimum_gas_price()

            # a normal gas strategy would increment by at least 10%
            # but we want to stay at the floor price. on fantom, that should still get picked up somewhat quickly
            # last_gas_price = last_gas_price * 1.101

            last_gas_price = min(min_price, last_gas_price)

            # this won't re-broadcast if <10% from the previous price
            yield last_gas_price
