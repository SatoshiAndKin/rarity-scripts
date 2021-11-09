"""Helpers for Fantom smart Contracts."""
from eth_utils import to_bytes

from brownie import network


def is_forked_network() -> bool:
    return network.show_active().endswith("-fork")


# TODO: there is probably a better way to do this
def to_bytes32(primitive=None, hexstr=None, text=None):
    return to_bytes(primitive, hexstr, text).ljust(32, b"\x00")
