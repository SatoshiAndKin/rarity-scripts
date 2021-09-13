// SPDX-License-Identifier: MPL-2.0
pragma solidity 0.8.7;

import {RarityCommon, IRarityAttributes} from "contracts/abstract/RarityCommon.sol";

/// @title a DELEGATECALL target contract for bulk actions in Rarity
/// @dev this does NOT implement the token receiver hooks. do NOT approve this contract!
contract RarityActionV2 is RarityCommon {

    function summon(uint class, uint amount, IRarityAttributes.ability_score calldata ability_score) external {
        uint summoner;
        for (uint i = 0; i < amount; i++) {
            summoner = RARITY.next_summoner();
            RARITY.summon(class);
            RARITY.adventure(summoner);

            if (ability_score.strength > 0) {
                RARITY_ATTRIBUTES.point_buy(
                    summoner,
                    ability_score.strength,
                    ability_score.dexterity,
                    ability_score.constitution,
                    ability_score.intelligence,
                    ability_score.wisdom,
                    ability_score.charisma
                );
            }

            // TODO: skills
            // TODO: name
        }
    }

    function adventure(uint[] calldata summoners) external {
        uint length = summoners.length;
        for (uint i = 0; i < length; i++) {
            RARITY.adventure(summoners[i]);
        }
    }

    /// @dev don't spend all your XP on levels if you want to craft items!
    function levelUp(uint[] calldata summoners) external {        
        uint length = summoners.length;
        for (uint i = 0; i < length; i++) {
            RARITY.level_up(summoners[i]);
        }
    }

    function claimGold(uint[] calldata summoners) external {
        uint length = summoners.length;
        for (uint i = 0; i < length; i++) {
            RARITY_GOLD.claim(summoners[i]);
        }
    }

    function levelUpAndClaimGold(uint[] calldata summoners) external {
        uint length = summoners.length;
        for (uint i = 0; i < length; i++) {
            RARITY.level_up(summoners[i]);
            RARITY_GOLD.claim(summoners[i]);
        }
    }
}