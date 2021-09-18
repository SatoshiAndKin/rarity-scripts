from collections import namedtuple
from enum import IntEnum

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


Summoner = namedtuple("Summoner", ["summoner", "xp", "log", "classId", "level"])


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
    with brownie.multicall:
        summoners = [(s, RARITY.summoner(s)) for s in summoners]

    # (uint _xp, uint _log, uint _class, uint _level)
    summoners = [Summoner(s, *x) for (s, x) in summoners]

    return summoners
