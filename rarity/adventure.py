from pprint import pprint

import brownie
import itertools
from click_spinner import spinner

from rarity.contracts import RARITY, RARITY_ACTION_V2, RARITY_MATERIALS_1
from rarity.summoner import get_summoners, get_xp_required
from rarity.utils import grouper


def adventure(with_level_up) -> int:
    # TODO: doing this in bulk might flag our PCs as NPCs. figure out how that system is going to work
    # this will prompt the user to load their account_address
    # if they type their passphrase wrong, best to quit now then after they've chosen stats
    account_address = brownie.accounts.default.address

    # TODO: why is this necessary? i thought setting default would make things work without this
    RARITY._owner = account_address
    RARITY_ACTION_V2._owner = account_address
    RARITY_MATERIALS_1._owner = account_address

    print("Querying summoners...")
    with spinner():
        summoners = get_summoners(account_address)

    print(f"{account_address} has {len(summoners)} known summoners")

    rarity_balance = RARITY.balanceOf(account_address)
    if rarity_balance != len(summoners):
        print(f"WARNING! Only {len(summoners)}/{rarity_balance} summoner ids are known!")

    # Version numbering is going to be tedious. so is approving every time a new contract comes out
    # get our clone proxies deployed on FTM and then approve that instead?

    print("Querying adventure's logs and scouting...")
    with spinner():
        with brownie.multicall:
            approvals = [(RARITY.getApproved(s.summoner), s) for s in summoners]
            adventurers_logs = [(RARITY.adventurers_log(s.summoner), s) for s in summoners]
            materials_1_logs = [(RARITY_MATERIALS_1.adventurers_log(s.summoner), s) for s in summoners]
            # TODO: get level

    # pprint(approvals)
    pprint(adventurers_logs)
    # pprint(materials_1_logs)

    print("Setting up approvals...")
    if not RARITY.isApprovedForAll.call(account_address, RARITY_ACTION_V2):
        RARITY.setApprovalForAll(RARITY_ACTION_V2, True, {"from": account_address, "required_confs": 0})

    # approvalForAll doesn't work on all contracts
    # TODO: these approvals aren't always needed
    for approved, summoner in approvals:
        if approved != RARITY_ACTION_V2.address:
            RARITY.approve(RARITY_ACTION_V2, summoner.summoner, {"from": account_address, "required_confs": 0})

    print("waiting for confirmations...")
    with spinner():
        brownie.history.wait()

    now = brownie.chain[-1].timestamp

    next_run = now + 86400

    for (next_adventure_timestamp, _) in itertools.chain(adventurers_logs, materials_1_logs):
        if now < next_adventure_timestamp:
            next_run = next_adventure_timestamp + 1
            break

    print("now:", now)
    print("next_run:", next_run)

    # filter out adventurers that have adventured too recently
    adventurers = [s.summoner for (l, s) in adventurers_logs if now > l]
    print(f"{account_address} has {len(adventurers)} summoners ready for adventure")
    if adventurers:
        # TODO: if connected to ganache, use grouper
        group_size = len(adventurers)
        for a in grouper(adventurers, group_size, None):
            # RARITY_ACTION_V2.adventure(list(filter(None, a)), {"required_confs": 0})
            pass

    # level up automatically? if we want to craft something, we don't want to!
    if with_level_up:
        leveled_summoners = [
            s.summoner
            for s in summoners
            if s.xp >= get_xp_required(s.level)
        ]
        print(f"{account_address} has {len(leveled_summoners)} summoners ready for leveling up")
        if leveled_summoners:
            group_size = 1  # len(leveled_summoners)
            for a in grouper(leveled_summoners, group_size, None):
                # TODO: levelUpAndClaimGold once i figure out approvals
                # RARITY_ACTION_V2.levelUp(list(filter(None, a)), {"required_confs": 0})
                pass

    # TODO: check claimable gold here instead?

    materials_1_adventurers = [
        s.summoner
        for (next_adventure_timestamp, s) in materials_1_logs
        if now > next_adventure_timestamp
    ]
    if materials_1_adventurers:
        print("Scouting for Materials 1...")
        with spinner():
            with brownie.multicall:
                materials_1_scout = [(RARITY_MATERIALS_1.scout(s), s) for s in materials_1_adventurers]

            materials_1_adventurers = [
                s
                for (i, s) in enumerate(materials_1_adventurers)
                if materials_1_scout[i][0] > 0
            ]

        print(f"{account_address} has {len(materials_1_adventurers)} summoners ready for collecting materials 1")

        if materials_1_adventurers:
            group_size = len(materials_1_adventurers)
            for a in grouper(materials_1_adventurers, group_size, None):
                # RARITY_ACTION_V2.distantAdventure(list(filter(None, a)), RARITY_MATERIALS_1, {"required_confs": 0})
                pass
    else:
        print(f"{account_address} has {len(materials_1_adventurers)} summoners ready for collecting materials 1")

    print("waiting for confirmations...")
    with spinner():
        brownie.history.wait()

    print("CONFIRMED!")

    for tx in brownie.history:
        tx.info()

    print("adventuring complete!")

    print("next run needed in", next_run - now, "seconds")

    return next_run - now
