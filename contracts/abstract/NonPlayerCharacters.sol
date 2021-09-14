// SPDX-License-Identifier: MPL-2.0
/**

    A rudimentary guild contract. Any member can steal everything!

    More advanced authentication could be done by having the leader be a timelocked multisig
    and the members be limited smart contracts.

 */
pragma solidity 0.8.7;

import "@OpenZeppelin/utils/structs/EnumerableSet.sol";
import "@OpenZeppelin/token/ERC721/IERC721.sol";

import {Owned} from "contracts/abstract/Owned.sol";
import {RarityCommon} from "contracts/abstract/RarityCommon.sol";

import "contracts/Errors.sol";

abstract contract NonPlayerCharacters is Owned, RarityCommon {
    /// @dev don't forget this on the inheriting contracts!
    using EnumerableSet for EnumerableSet.UintSet;

    struct Call {
        address target;
        bool delegate;
        bytes data;
    }
    struct Result {
        bool success;
        bytes returnData;
    }

    //
    // Game state
    //

    /// @dev DELEGATECALL target for the "act" function (allows upgrades)
    address public actTarget;

    /// @dev The class of all the npcs
    uint[] public classes;

    /// @dev track the timestamp that the first npc last adventured
    uint internal firstNPCAdventureLog;

    /// @dev a group of NPCs must have a name
    string public name;

    /// @dev the next summoner that is ready for adventure. if > npcs.length, summon more
    /// TODO: helper function to reset this in case of some bug? worst case its stuck for a day
    uint public nextNPC;

    /// @dev A list of NPC npcs
    EnumerableSet.UintSet internal npcs;

    //
    // Non-game state
    //

    /// @dev This contract has been initialized
    bool private initialized;
    /// @dev The original address of this contract
    address private immutable original;
    
    //
    // Setup functions
    //

    /// @notice a mostly empty constructor. use createNewGuild to actually make a place.
    constructor() {
        // save this address in the bytecode so that we can check for delegatecalls
        original = address(this);
    }

    struct InitData {
        address actTarget;
        uint[] classes;
        string name;
        address owner;

    }

    function initialize(bytes calldata data) external {
        // security checks
        require(address(this) != original, "!delegatecall");
        require(!initialized, "!initialize");

        initialized = true;

        (InitData memory initData) = abi.decode(data, (InitData));

        actTarget = initData.actTarget;
        classes = initData.classes;
        name = initData.name;
        Owned.initialize(initData.owner);
    }

    //
    // Primary functions
    //

    /// @notice the standard act function
    function act(uint actingNpcs) authSender external {
        require(actingNpcs > 0, "!workNum");

        if (block.timestamp > firstNPCAdventureLog) {
            // the first summoner is able to adventure again
            nextNPC = 0;
        }
        if (nextNPC == 0) {
            firstNPCAdventureLog = block.timestamp;
        }

        uint currentNPCs = npcs.length();

        if (nextNPC + actingNpcs > currentNPCs) {
            // summon more npcs
            uint npcsNeeded = nextNPC + actingNpcs - currentNPCs;
            for (uint i = 0; i < npcsNeeded; i++) {
                _summon();
            }
        }

        // do some adventuring (and maybe more)
        for (uint i = 0; i < actingNpcs; i++) {
            uint summoner = npcs.at(nextNPC + i);

            // base adventure
            try RARITY.adventure(summoner) {
                // it worked
            } catch (bytes memory /*lowLevelData*/) {
                // it failed
            }

            // we do NOT automatically level up because we might want that xp for crafting

            // we do NOT check success status. one might fail and the next could succeed
            if (actTarget != address(0)) {
                (bool success, bytes memory ret) = actTarget.delegatecall(abi.encodeWithSignature("act(uint)", summoner));

                if (!success) {
                    revert CallReverted(actTarget, true, abi.encodeWithSignature("act(uint)", summoner), ret);
                }
            }
        }
    }

    /// @notice Take full control of the NPCs
    function control(Call[] memory calls) authSender external returns (bytes[] memory returnData) {
        uint callsLength = calls.length;

        returnData = new bytes[](callsLength);
        bytes memory ret;
        bool success;

        for (uint256 i = 0; i < callsLength; i++) {
            if (calls[i].delegate == true) {
                (success, ret) = calls[i].target.delegatecall(calls[i].data);
            } else {
                (success, ret) = calls[i].target.call(calls[i].data);
            }
            if (!success) {
                revert CallReverted(calls[i].target, calls[i].delegate, calls[i].data, ret);
            }
            returnData[i] = ret;
        }
    }

    /// @dev summon a summoner for this group of NPCs
    function _summon() internal {
        // rotate through the classes
        uint class = classes[npcs.length() % classes.length];

        uint summoner = RARITY.next_summoner();
        RARITY.summon(class);

        _setup_summon(class, summoner);
    }

    /// @dev override this to call more during "_summon"
    function _setup_summon(uint class, uint summoner) internal virtual;

    //
    // State functions
    //

    function npcAt(uint index) external view returns (uint) {
        return npcs.at(index);
    }

    function npcCount(uint index) external view returns (uint) {
        return npcs.length();
    }

    //
    // Recovery functions
    //

    /// @dev fix nextNPC (hopefully never needed)
    function setNextSummoner(uint _next) external authSender {
        nextNPC = _next;
    }

    //
    // Token standards
    //

    /// @dev support ERC165
    function supportsInterface(bytes4 interfaceID) external pure returns (bool) {
        return  interfaceID == 0x01ffc9a7 ||    // ERC-165 support (i.e. `bytes4(keccak256('supportsInterface(bytes4)'))`).
                interfaceID == 0x80ac58cd       // ERC-721 support
        ;
    }

    /// @dev receive ERC721 tokens
    function onERC721Received(address /*operator*/, address /*from*/, uint256 tokenId, bytes calldata) external returns(bytes4) {
        require(RARITY.ownerOf(tokenId) == address(this), "wtf");

        npcs.add(tokenId);

        // TODO: depending on when they last adventured, this could be not great

        return this.onERC721Received.selector;
    }

}
