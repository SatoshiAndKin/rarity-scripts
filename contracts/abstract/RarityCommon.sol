// SPDX-License-Identifier: MPL-2.0
pragma solidity 0.8.7;

import {IRarity} from "contracts/external/rarity/IRarity.sol";
import {IRarityAdventure} from "contracts/external/rarity/IRarityAdventure.sol";
import {IRarityAttributes} from "contracts/external/rarity/IRarityAttributes.sol";
import {IRarityCraft} from "contracts/external/rarity/IRarityCraft.sol";
import {IRarityCraftMaterials} from "contracts/external/rarity/IRarityCraftMaterials.sol";
import {IRarityGold} from "contracts/external/rarity/IRarityGold.sol";
import {IRaritySkills} from "contracts/external/rarity/IRaritySkills.sol";

import "contracts/infrastructure/Errors.sol";

abstract contract RarityCommon {

    IRarity internal constant RARITY = IRarity(0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb);
    IRarityGold internal constant RARITY_GOLD = IRarityGold(0x2069B76Afe6b734Fb65D1d099E7ec64ee9CC76B2);
    IRarityAttributes internal constant RARITY_ATTRIBUTES = 
        IRarityAttributes(0xB5F5AF1087A8DA62A23b08C00C6ec9af21F397a1);
    IRarityCraft internal constant RARITY_CRAFT_1 = IRarityCraft(0xf41270836dF4Db1D28F7fd0935270e3A603e78cC);
    IRarityCraftMaterials internal constant RARITY_CRAFT_MATS_1 =
        IRarityCraftMaterials(0x2A0F1cB17680161cF255348dDFDeE94ea8Ca196A);
    IRaritySkills internal constant RARITY_SKILLS = IRaritySkills(0x51C0B29A1d84611373BA301706c6B4b72283C80F);
    // TODO: what else? Names?

    uint immutable RARITY_CRAFT_ID;

    constructor() {
        RARITY_CRAFT_ID = RARITY_CRAFT_1.SUMMMONER_ID();
    }

    function _isApprovedOrOwner(address spender, uint256 summoner) internal view returns (bool) {
        // require(_exists(summoner), "ERC721: operator query for nonexistent token");
        address summoner_owner = RARITY.ownerOf(summoner);
        return (
            spender == summoner_owner
            || RARITY.getApproved(summoner) == spender
            || RARITY.isApprovedForAll(summoner_owner, spender)
        );
    }

    function requireAuthSummoner(uint summoner) internal view {
        // TODO: if delgatecall, allow?
        if (!_isApprovedOrOwner(msg.sender, summoner)) {
            revert NotApprovedOrOwner(msg.sender, summoner);
        }
    }
}
