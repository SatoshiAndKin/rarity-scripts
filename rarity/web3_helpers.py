"""Helpers for Fantom smart Contracts."""
from brownie import Contract, web3
from eth_utils import keccak, to_bytes, to_checksum_address


def get_or_create(
    account, contract, constructor_args=None, salt=None
) -> Contract:
    """Use CREATE2 and a set deployer address to deploy a contract with a deterministic address."""
    if constructor_args is None:
        constructor_args = []

    contract_initcode = contract.deploy.encode_input(*constructor_args)

    # SingletonFactory doesn't work on FTM. We use Andre's factory instead
    create2_deployer = Contract("0x54f5a04417e29ff5d7141a6d33cb286f50d5d50e")

    contract_address = calculate_create2_address(
        str(create2_deployer.address), contract_initcode, salt=salt
    )

    if web3.eth.get_code(contract_address).hex() == "0x":
        # the contract does not exist yet
        create2_deployer.deploy(contract_initcode, salt, {"from": account})
        print(f"Created {contract._name} at {contract_address}\n")
    else:
        # the contract has already been deployed
        print(f"Found {contract._name} at {contract_address}\n")

    return contract.at(contract_address, account)


def calculate_create2_address(sender: str, initcode: str, salt: str = None) -> str:
    """Calculate the determinstic Create2 address."""
    sender_bytes = to_bytes(hexstr=sender)

    if isinstance(salt, bytes):
        # TODO: pad the bytes
        pass
    elif not salt:
        salt = to_bytes32(text="")
    elif salt.startswith("0x"):
        salt = to_bytes32(hexstr=salt)
    elif isinstance(salt, str):
        salt = to_bytes32(text=salt)
    else:
        raise ValueError("Unrecognized type for salt")

    # TODO: pad the salt if it is too short

    initcode_hash = keccak(to_bytes(hexstr=initcode))

    raw = b"\xff" + sender_bytes + salt + initcode_hash

    assert len(raw) == 85, "incorrect length of inputs!"

    address_bytes = keccak(raw)[-20:]

    return to_checksum_address(address_bytes)


# TODO: there is probably a better way to do this
def to_bytes32(primitive=None, hexstr=None, text=None):
    return to_bytes(primitive, hexstr, text).ljust(32, b"\x00")
