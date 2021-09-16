import click
from collections import namedtuple
from enum import IntEnum

from brownie import Contract, multicall, web3
from lazy_load import lazy_func
from eth_utils import keccak, to_bytes, to_checksum_address

from rarity.web3_helpers import to_bytes32

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


lazy_contract = lazy_func(Contract)


RARITY = lazy_contract("0xce761d788df608bd21bdd59d6f4b54b2e27f25bb")
RARITY_ATTRIBUTES = lazy_contract("0xB5F5AF1087A8DA62A23b08C00C6ec9af21F397a1")
RARITY_CRAFT_1 = lazy_contract("0x2A0F1cB17680161cF255348dDFDeE94ea8Ca196A")
RARITY_CRAFTING_1 = lazy_contract("0x3FC0539D1a0737FCA3e4556A990AAE1C38425F14")
RARITY_GOLD = lazy_contract("0x2069B76Afe6b734Fb65D1d099E7ec64ee9CC76B2")
RARITY_SKILLS = lazy_contract("0x51C0B29A1d84611373BA301706c6B4b72283C80F")

RARITY_CODEX_RANDOM = lazy_contract("0x7426dBE5207C2b5DaC57d8e55F0959fcD99661D4")
RARITY_CODEX_SKILLS = lazy_contract("0x67ae39a2Ee91D7258a86CD901B17527e19E493B3")
RARITY_CODEX_CLASS_SKILLS = lazy_contract("0xf677eD67B7717f3a743BE8D9b6662B11b095DB43")
RARITY_CODEX_FEATS_1 = lazy_contract("0x822F888f5DB8e1316717Eb904E550ebB1196EdbE")
RARITY_CODEX_ITEMS_GOODS = lazy_contract("0x0C5C1CC0A7AE65FE372fbb08FF16578De4b980f3")
RARITY_CODEX_ITEMS_ARMOR = lazy_contract("0xf5114A952Aca3e9055a52a87938efefc8BB7878C")
RARITY_CODEX_ITEMS_WEAPONS = lazy_contract("0xeE1a2EA55945223404d73C0BbE57f540BBAAD0D8")


RARITY_ACTION_V2 = lazy_contract(lambda: get_or_create(None, ArgobytesBrownieProject.RarityActionV2))

Summoner = namedtuple("Summoner", ["summoner", "xp", "log", "classId", "level"])


class RarityBaseClass(IntEnum):
    # NONE = 0
    BARBARIAN = 1
    BARD = 2
    CLERIC = 3
    DRUID = 4
    FIGHTER = 5
    MONK = 6
    PALADIN = 7
    RANGER = 8
    ROGUE = 9
    SORCERER = 10
    WIZARD = 11


# TODO: enum for prestige classes


def grouper(iterable, n, fillvalue=None):
    """Collect data into fixed-length chunks or blocks
    https://docs.python.org/3/library/itertools.html
    """
    # grouper('ABCDEFG', 3, 'x') --> ABC DEF Gxx"
    args = [iter(iterable)] * n
    return itertools.zip_longest(*args, fillvalue=fillvalue)


def get_summoners(account, limit=1000):
    # Select your transport with a defined url endpoint
    transport = RequestsHTTPTransport(url="https://api.thegraph.com/subgraphs/name/eabz/rarity")

    # Create a GraphQL client using the defined transport
    client = Client(transport=transport, fetch_schema_from_transport=True)

    # TODO: compare graphql result with balanceOf
    # TODO: also query level and class? anything else? gold?
    # TODO: how should we paginate? https://thegraph.com/docs/developer/graphql-api#pagination isn't working for me
    query = gql(
        """
    {{
        summoners(where: {{owner: "{account}"}}, first: {limit}) {{
            id
            }}
    }}
    """.format(
            account=account.address.lower(),
            limit=limit,
        )
    )

    result = client.execute(query)

    # TODO: scan transactions for new summoners if the balance doesn't match

    summoners = [x["id"] for x in result["summoners"]]

    # the graph might be behind, so get the data out of the chain
    with multicall:
        summoners = [(s, RARITY.summoner(s)) for s in summoners]

    # (uint _xp, uint _log, uint _class, uint _level)
    summoners = [Summoner(s, *x) for (s, x) in summoners]

    return summoners
