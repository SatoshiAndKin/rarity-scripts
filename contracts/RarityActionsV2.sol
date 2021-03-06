// SPDX-License-Identifier: MPL-2.0
pragma solidity 0.8.7;

import {DelegateGuard} from "contracts/infrastructure/DelegateGuard.sol";
import {IRarityAdventure, IRarityAttributes, RarityCommon} from "contracts/abstract/RarityCommon.sol";

/// @title a DELEGATECALL target contract for bulk actions in Rarity
/// @dev this does NOT implement the token receiver hooks. do NOT approve this contract!
contract RarityActionsV2 is DelegateGuard, RarityCommon {

    function adventure(uint[] calldata summoners) external {
        uint length = summoners.length;
        for (uint i = 0; i < length; i++) {
            requireAuthSummoner(summoners[i]);
            try RARITY.adventure(summoners[i]) {
                // it worked       
            } catch (bytes memory /*lowLevelData*/) {
                // it failed
            }
        }
    }

    function claimGold(uint[] calldata summoners) external {
        uint length = summoners.length;
        for (uint i = 0; i < length; i++) {
            requireAuthSummoner(summoners[i]);
            RARITY_GOLD.claim(summoners[i]);
        }
    }

    function approveGold(uint[] calldata summoners, uint spender) external {
        uint length = summoners.length;
        for (uint i = 0; i < length; i++) {
            requireAuthSummoner(summoners[i]);
            RARITY_GOLD.approve(summoners[i], spender, 2 ** 256 - 1);
        }
    }

    function distantAdventure(uint[] calldata summoners, IRarityAdventure quest) external {
        uint length = summoners.length;
        for (uint i = 0; i < length; i++) {
            requireAuthSummoner(summoners[i]);
            if (quest.scout(summoners[i]) > 0) {
                try quest.adventure(summoners[i]) {
                    // it worked       
                } catch (bytes memory /*lowLevelData*/) {
                    // it failed
                }
            }
        }
    }

    function increaseStrength(uint[] calldata summoners) external {
        uint length = summoners.length;
        for (uint i = 0; i < length; i++) {
            requireAuthSummoner(summoners[i]);
            RARITY_ATTRIBUTES.increase_strength(summoners[i]);
        }
    }

    function increaseDexterity(uint[] calldata summoners) external {
        uint length = summoners.length;
        for (uint i = 0; i < length; i++) {
            requireAuthSummoner(summoners[i]);
            RARITY_ATTRIBUTES.increase_dexterity(summoners[i]);
        }
    }

    function increaseConstitution(uint[] calldata summoners) external {
        uint length = summoners.length;
        for (uint i = 0; i < length; i++) {
            requireAuthSummoner(summoners[i]);
            RARITY_ATTRIBUTES.increase_constitution(summoners[i]);
        }
    }

    function increaseIntelligence(uint[] calldata summoners) external {
        uint length = summoners.length;
        for (uint i = 0; i < length; i++) {
            requireAuthSummoner(summoners[i]);
            RARITY_ATTRIBUTES.increase_intelligence(summoners[i]);
        }
    }

    function increaseWisdom(uint[] calldata summoners) external {
        uint length = summoners.length;
        for (uint i = 0; i < length; i++) {
            requireAuthSummoner(summoners[i]);
            RARITY_ATTRIBUTES.increase_wisdom(summoners[i]);
        }
    }

    function increaseCharisma(uint[] calldata summoners) external {
        uint length = summoners.length;
        for (uint i = 0; i < length; i++) {
            requireAuthSummoner(summoners[i]);
            RARITY_ATTRIBUTES.increase_charisma(summoners[i]);
        }
    }

    /// @dev don't spend all your XP on levels if you want to craft items!
    function levelUp(uint[] calldata summoners) external {        
        uint length = summoners.length;
        for (uint i = 0; i < length; i++) {
            requireAuthSummoner(summoners[i]);
            RARITY.level_up(summoners[i]);
        }
    }

    /// @dev don't spend all your XP on levels if you want to craft items!
    function levelUpAndClaimGold(uint[] calldata summoners) external {
        uint length = summoners.length;
        for (uint i = 0; i < length; i++) {
            requireAuthSummoner(summoners[i]);
            RARITY.level_up(summoners[i]);
            RARITY_GOLD.claim(summoners[i]);
        }
    }

    function setSkills(uint[] calldata summoners, uint8[36] memory skills) external {
        uint length = summoners.length;
        for (uint i = 0; i < length; i++) {
            requireAuthSummoner(summoners[i]);
            RARITY_SKILLS.set_skills(summoners[i], skills);
        }
    }

    function summon(
        uint amount,
        uint class,
        IRarityAttributes.ability_score calldata ability_score
    ) external {
        // transfer the summoner if we aren't in a DELEGATECALL
        bool transfer_summoner = address(this) == original;

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
            // to set skills, call "setSkills"

            if (transfer_summoner) {
                RARITY.safeTransferFrom(address(this), msg.sender, summoner);
            }
        }
    }

    function sweepGold(uint[] calldata summoners, uint to) external {
        uint balance;

        uint length = summoners.length;
        for (uint i = 0; i < length; i++) {
            requireAuthSummoner(summoners[i]);

            balance = RARITY_GOLD.balanceOf(summoners[i]);

            RARITY_GOLD.transfer(summoners[i], to, balance);
        }
    }
}
