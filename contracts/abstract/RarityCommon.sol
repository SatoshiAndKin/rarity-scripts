// SPDX-License-Identifier: MPL-2.0
pragma solidity 0.8.7;

import {IRarity} from "contracts/external/rarity/IRarity.sol";
import {IRarityAdventure} from "contracts/external/rarity/IRarityAdventure.sol";
import {IRarityAttributes} from "contracts/external/rarity/IRarityAttributes.sol";
import {IRarityGold} from "contracts/external/rarity/IRarityGold.sol";
import {IRaritySkills} from "contracts/external/rarity/IRaritySkills.sol";

error NotApprovedOrOwner(address who, uint summoner);

abstract contract RarityCommon {

    IRarity internal constant RARITY = IRarity(0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb);
    IRarityGold internal constant RARITY_GOLD = IRarityGold(0x2069B76Afe6b734Fb65D1d099E7ec64ee9CC76B2);
    IRarityAttributes internal constant RARITY_ATTRIBUTES = IRarityAttributes(0xB5F5AF1087A8DA62A23b08C00C6ec9af21F397a1);
    IRaritySkills internal constant RARITY_SKILLS = IRaritySkills(0x51C0B29A1d84611373BA301706c6B4b72283C80F);
    // TODO: what else? Names? Craft? Crafting?

    function _isApprovedOrOwner(address spender, uint256 summoner) internal view returns (bool) {
        // require(_exists(summoner), "ERC721: operator query for nonexistent token");
        address summoner_owner = RARITY.ownerOf(summoner);
        return (spender == summoner_owner || RARITY.getApproved(summoner) == spender || RARITY.isApprovedForAll(summoner_owner, spender));
    }

    function requireAuthSummoner(uint summoner) internal view {
        // TODO: if delgatecall, allow?
        if (!_isApprovedOrOwner(msg.sender, summoner)) {
            revert NotApprovedOrOwner(msg.sender, summoner);
        }
    }
}
