"""Helpers for Fantom smart Contracts."""
from brownie import Contract, web3
from eth_utils import keccak, to_bytes, to_checksum_address


# TODO: there is probably a better way to do this
def to_bytes32(primitive=None, hexstr=None, text=None):
    return to_bytes(primitive, hexstr, text).ljust(32, b"\x00")
