// SPDX-License-Identifier: MPL-2.0
/**

    A rudimentary guild contract. Any member can steal everything!

    More advanced authentication could be done by having the leader be a timelocked multisig
    and the members be limited smart contracts.

    Alternate name: SummoningCircle.sol

 */
pragma solidity 0.8.7;

import "@OpenZeppelin/utils/structs/EnumerableSet.sol";
import "@OpenZeppelin/token/ERC721/IERC721.sol";

import {CloneFactory, OwnedCloneable} from "contracts/abstract/OwnedCloneable.sol";
import {RarityCommon} from "contracts/abstract/RarityCommon.sol";

import "contracts/infrastructure/Errors.sol";

contract NonPlayerCharacters is OwnedCloneable, RarityCommon {
    /// @dev don't forget this on the inheriting contracts!
    using EnumerableSet for EnumerableSet.UintSet;

    struct InitData {
        address actTarget;
        ClassData[] classes;
        string name;
        address owner;
    }

    struct ClassData {
        uint id;
        uint32[6] ability;
        uint8[40] skills;
    }

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
    ClassData[] public classes;

    /// @dev track the index of the first npc. indexes earlier than this has moved out
    uint public firstNPCIndex;

    /// @dev track the timestamp that the first npc last adventured
    uint internal firstNPCAdventureLog;

    /// @dev a group of NPCs must have a name
    string public name;

    /// @dev the next summoner that is ready for adventure. if > npcs.length, summon more
    uint public nextNPCIndex;

    /// @dev A list of NPC npcs
    // TODO: how should removing elements work?
    uint[] public npcs;

    //
    // Non-game state
    //

    bool private initialized;

    //
    // Setup functions
    //

    /// @notice setup contract implementation. Don't call this yourself; use "newNonPlayerCharacters"
    constructor(CloneFactory _cloneFactory) OwnedCloneable(_cloneFactory) {}

    /// @notice setup contract state. Don't call this yourself; use "newNonPlayerCharacters"
    function initialize(InitData calldata initData) external {
        // security checks
        requireDelegateCall();
        require(!initialized, "!initialize");

        initialized = true;

        actTarget = initData.actTarget;

        uint classesLength = initData.classes.length;
        for (uint i = 0; i < classesLength; i++) {
            classes[i] = initData.classes[i];
        }

        name = initData.name;
        OwnedCloneable.initialize(initData.owner);
    }

    function newNonPlayerCharacters(InitData calldata initData, bytes32 salt) external returns (address clone) {
        requireCallOriginal();

        bytes32 pepper = keccak256(abi.encode(initData, salt));

        clone = cloneFactory.cloneTarget(address(this), pepper);

        NonPlayerCharacters(clone).initialize(initData);
    }

    //
    // Primary functions
    //

    /// @notice the standard act function
    function act(uint actingNpcs) external {
        requireOwnerSender();

        require(actingNpcs > 0, "!actingNpcs");

        if (block.timestamp > firstNPCAdventureLog) {
            // the first summoner is able to adventure again
            nextNPCIndex = 0;
        }
        if (nextNPCIndex == 0) {
            firstNPCAdventureLog = block.timestamp;
        }

        uint currentNPCs = npcs.length;

        if (nextNPCIndex + actingNpcs > currentNPCs) {
            // summon more npcs
            uint npcsNeeded = nextNPCIndex + actingNpcs - currentNPCs;
            for (uint i = 0; i < npcsNeeded; i++) {
                summon();
            }
        }

        // do some adventuring (and maybe more)
        for (uint i = 0; i < actingNpcs; i++) {
            uint summoner = npcs[nextNPCIndex + i];

            // base adventure
            try RARITY.adventure(summoner) {
                // it worked
            } catch (bytes memory /*lowLevelData*/) {
                // it failed
            }

            // we do NOT automatically level up because we might want that xp for crafting

            // we do NOT check success status. one might fail and the next could succeed
            if (actTarget != address(0)) {
                (bool success, bytes memory ret) = actTarget.delegatecall(
                    abi.encodeWithSignature("act(uint)", summoner)
                );

                if (!success) {
                    revert CallReverted(actTarget, true, abi.encodeWithSignature("act(uint)", summoner), ret);
                }
            }
        }
    }

    /// @notice Take full control of the NPCs
    function control(Call[] memory calls) external returns (bytes[] memory returnData) {
        requireOwnerSender();

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

    /// @notice Send a summoner to this contract.
    function giveSummoner(address from, address to, uint summoner, uint _npcClassIndex) external {    
        bool npcClassFound = false;

        uint classesLength = classes.length;
        for (uint i = 0; i < classesLength; i++) {
            if (i == _npcClassIndex) {
                ClassData memory npcClass = classes[_npcClassIndex];

                uint classId = RARITY.class(summoner);
                require(classId == npcClass.id, "!class");

                RARITY.transferFrom(from, to, summoner);

                // this will revert if the summoner doesn't fit the npcClass
                _summon_setup(summoner, npcClass);

                npcClassFound = true;
            } else if (msg.sender != owner()) {
                // if there are multiple class types on this contract, someone could spam us with just 1 of them
                // so we spawn the ones they aren't adding
                // TODO: think about this more

                _summon(i);
            }
        }

        require(npcClassFound, "!npcClass");
    }

    /// @notice summon a new summoner for this contract (no auth needed)
    function summon() public {
        // rotate through the classes
        uint nextNpcClass = npcs.length % classes.length;

        _summon(nextNpcClass);
    }

    /// @dev summon a summoner for this group of NPCs
    function _summon(uint _npcClass) internal {
        uint summoner = RARITY.next_summoner();

        ClassData memory classData = classes[_npcClass];

        RARITY.summon(classData.id);

        _summon_setup(summoner, classData);
    }

    /// @dev called by _summon and giveSummmoner to set skills and ability scores
    function _summon_setup(uint summoner, ClassData memory classData) internal {
        // TODO: check ability scores and spend points (revert if not possible)

        // TODO: check skills and spend skill points (revert if not possible)

        // contracts that extend NonPlayerCharacters can do whatever they want next
        _summon_setup_more(summoner, classData);
    }

    /// @dev override this to call more during "_summon"
    /// @dev this must be written in a way that allows for existing summoners to be configured
    function _summon_setup_more(uint summoner, ClassData memory classData) internal virtual {}

    /// @notice send a summoner from this contract to another address.
    function transferSummoner(address to) external {
        requireOwnerSender();

        _transferSummoner(to, firstNPCIndex);
    }

    /// @dev send the first NPC out of this contract
    function _transferSummoner(address to, uint summoner) internal {
        RARITY.safeTransferFrom(address(this), msg.sender, summoner);

        npcs[firstNPCIndex] = 0;

        firstNPCIndex += 1;
    }

    //
    // Recovery functions
    //

    /// @notice fix nextNPCIndex (hopefully never needed)
    function setNextNPC(uint _index) external {
        requireOwnerSender();

        nextNPCIndex = _index;
    }

    //
    // Token standards
    //

    /// @dev support ERC165
    function supportsInterface(bytes4 interfaceID) external pure returns (bool) {
        return  interfaceID == 0x01ffc9a7 ||    // ERC-165 support
                interfaceID == 0x80ac58cd       // ERC-721 support
        ;
    }

    /// @dev receive known Rarity summoners spawned by this contract
    // TODO: have another contract that can receive any summoner? for now, the RarityGuild fills that role
    // TODO: or (since we check operator and not from) you can have a safe function that transferFroms valid summoers
    /// @dev the standard limits this to 30k gas, but RARITY does not
    function onERC721Received(
        address operator,
        address /*from*/,
        uint summoner,
        bytes calldata
    ) external returns(bytes4) {
        require(RARITY.ownerOf(summoner) == address(this), "!rarity");

        // only allow summoners summoned by this contract. no external transfers allowed
        // to give a summoner to this contract, call "giveSummoner"
        require(operator == address(this), "!auth");

        npcs.push(summoner);

        return this.onERC721Received.selector;
    }
}
