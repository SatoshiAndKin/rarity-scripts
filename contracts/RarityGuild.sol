// SPDX-License-Identifier: MPL-2.0
/**

    A rudimentary guild contract. Any member can steal everything or brick the contract by making a bad call!

    More advanced authentication could be done by having the leader be a timelocked multisig
    and the members be limited smart contracts. We will write this eventually, but the game just came out. 

 */
pragma solidity 0.8.7;

import "@OpenZeppelin/utils/structs/EnumerableSet.sol";
import "@OpenZeppelin/token/ERC721/IERC721.sol";

import {RarityCommon} from "contracts/abstract/RarityCommon.sol";
import {CloneFactory} from "contracts/infrastructure/CloneFactory.sol";
import {OwnedCloneable} from "contracts/abstract/OwnedCloneable.sol";

import "contracts/infrastructure/Errors.sol";


/// @title A NFT-owning contract for playing blockchain games
/// @author Bryan Stitt <bryan@satoshiandkin.com>
contract RarityGuild is OwnedCloneable, RarityCommon {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    /// @dev data for a contract call
    /// @dev be super careful with delegatecalls! do not delegatecall a contract that uses state! that can break our state!
    struct Play {
        address target;
        bool delegateCall;
        bytes targetData;
    }
    /// @dev return of a contract call
    struct Result {
        bool success;
        bytes returnData;
    }

    /// @dev data for initializing 
    struct InitData {
        address[] members;
        string name;
        address owner;
        string url;
        IERC721 erc721ProfileToken;
        uint erc721ProfileId;
    }

    //
    // game state
    //

    /// @dev summoners that are owned by the Guild. Any member can control them.
    EnumerableSet.UintSet internal guild_summoners;

    /// @dev accounts that are able to control the Guild
    EnumerableSet.AddressSet internal members;

    /// @dev summoners that are owned by guild member and approved for this contract
    EnumerableSet.UintSet internal member_summoners;

    /// @dev The guild's name
    string public name;
    /// @dev The guild's url
    string public url;
    /// @dev The guild's profile picture (plus whatever metadata)
    IERC721 public erc721ProfileToken;
    uint public erc721ProfileId;

    //
    // non-game state and immutables
    //

    /// @dev This contract has been initialized
    bool private initialized;

    //
    // events
    //

    event AddMember(address indexed by, address member);
    event RemoveMember(address indexed by, address member);

    event SetName(address indexed by, string);
    event SetContact(address indexed by, string);
    event SetProfile(address indexed by, address erc721token, uint tokenId);

    //
    // Setup functions
    //

    /// @notice setup contract implementation. Don't call this yourself; use "newGuild"
    constructor(CloneFactory _cloneFactory) OwnedCloneable(_cloneFactory) {}

    /// @notice setup contract state. Don't call this yourself; use "newGuild"
    function initialize(InitData calldata initData) external {
        requireDelegateCall();
        require(!initialized, "!initialize");

        initialized = true;

        uint membersLength = initData.members.length;
        for (uint i = 1; i < membersLength; i++) {
            members.add(initData.members[i]);
        }

        name = initData.name;

        OwnedCloneable.initialize(initData.owner);

        url = initData.url;
        erc721ProfileToken = initData.erc721ProfileToken;
        erc721ProfileId = initData.erc721ProfileId;
    }
    
    /// @notice create your own guild
    function newGuild(InitData calldata initData, bytes32 salt) external returns (address guild) {
        requireCallOriginal();

        bytes32 pepper = keccak256(abi.encode(initData, salt));

        guild = cloneFactory.cloneTarget(address(this), pepper);

        RarityGuild(guild).initialize(initData);
    }

    //
    // Authorization functions
    //

    /// @notice Require the sender to be a guild member of the guild owner
    function requireMemberSender() internal {
        if (members.contains(msg.sender) || msg.sender == owner()) {
            return;
        }
        revert NotAuthorized(owner(), msg.sender);
    }

    //
    // Primary functions
    //

    /// @notice Play Rarity by combining one or more plays into one transaction
    function play(Play[] memory plays) external returns (bytes[] memory returnData) {
        requireMemberSender();

        uint playsLength = plays.length;

        returnData = new bytes[](playsLength);
        bytes memory ret;
        bool success;

        for (uint256 i = 0; i < playsLength; i++) {
            if (plays[i].delegateCall == true) {
                (success, ret) = plays[i].target.delegatecall(plays[i].targetData);
            } else {
                (success, ret) = plays[i].target.call(plays[i].targetData);
            }
            if (!success) {
                revert CallReverted(plays[i].target, plays[i].delegateCall, plays[i].targetData, ret);
            }
            returnData[i] = ret;
        }
    }
    
    //
    // Profile functions
    //

    /// @notice if ownership changed, clear the profile NFT (callable by anyone!)
    function clearProfile() external {
        if (erc721ProfileToken.ownerOf(erc721ProfileId) == address(this)) {
            revert ProfileValid();
        }

        erc721ProfileToken = IERC721(address(0));
        erc721ProfileId = 0;

        emit SetProfile(msg.sender, address(erc721ProfileToken), erc721ProfileId);
    }

    /// @notice Return the Guild's profile
    function profile() external view returns (string memory, string memory, address, uint) {
        return (name, url, address(erc721ProfileToken), erc721ProfileId);
    }

    /// @notice Set the Guild's contact info
    function setUrl(string calldata _url) external {
        requireOwnerSender();

        url = _url;

        emit SetContact(msg.sender, _url);
    }

    /// @notice Set the Guild's name
    function setName(string calldata _name) external {
        requireOwnerSender();

        name = _name;

        emit SetName(msg.sender, _name);
    }

    /// @notice Set the Guild's profile NFT
    function setProfile(IERC721 erc721Token, uint erc721TokenId) external {
        requireOwnerSender();

        address profileOwner = erc721Token.ownerOf(erc721TokenId);
        if (profileOwner != address(this)) {
            revert NotAuthorized(address(this), profileOwner);
        }

        erc721ProfileToken = erc721Token;
        erc721ProfileId = erc721TokenId;

        emit SetProfile(msg.sender, address(erc721Token), erc721TokenId);
    }

    //
    // Token standards
    //

    /// @notice allow receiving Rarity summoners from guild members
    function onERC721Received(address /*operator*/, address /*from*/, uint256 summoner, bytes calldata) external returns(bytes4) {
        require(RARITY.ownerOf(summoner) == address(this), "!rarity");

        // check the adventure log of the summoner. otherwise iterating the list of npcs gets weird
        uint adventure_log = RARITY.adventurers_log(summoner);
        require(block.timestamp > adventure_log, "!adventure_log");

        guild_summoners.add(summoner);

        // TODO: do we need this? seems safe but it might be done for us already
        RARITY.approve(address(0), summoner);

        return this.onERC721Received.selector;
    }

    /// @notice allow receiving ERC1155 tokens
    function onERC1155Received(address, address, uint256, uint256, bytes calldata) external pure returns(bytes4) {
        return this.onERC1155Received.selector;
    }

    /// @notice allow batch receiving ERC1155 tokens
    function onERC1155BatchReceived(address, address, uint256[] calldata, uint256[] calldata, bytes calldata)
        external pure returns(bytes4)
    {
        return this.onERC1155BatchReceived.selector;
    }

    /// @notice support ERC165
    function supportsInterface(bytes4 interfaceID) external pure returns (bool) {
        return  interfaceID == 0x01ffc9a7 ||    // ERC-165 support
                interfaceID == 0x80ac58cd ||    // ERC-721 TokenReceiver support
                interfaceID == 0x4e2312e0       // ERC-1155 TokenReceiver support
        ;
    }
}
