// SPDX-License-Identifier: MPL-2.0
/**

    A rudimentary guild contract. Any member can steal everything!

    More advanced authentication could be done by having the leader be a timelocked multisig
    and the members be limited smart contracts.

 */
pragma solidity 0.8.7;

import "./Errors.sol";

import "@OpenZeppelin/utils/structs/EnumerableSet.sol";
import "@OpenZeppelin/token/ERC721/IERC721.sol";

import {CloneFactory} from "./CloneFactory.sol";
import {Owned} from "./abstract/Owned.sol";

/// @title A NFT-owning contract for playing blockchain games
/// @author Bryan Stitt <bryan@satoshiandkin.com>
contract Guild is Owned {
    using EnumerableSet for EnumerableSet.AddressSet;

    struct Call {
        address target;
        bool delegate;
        bytes data;
    }
    struct Result {
        bool success;
        bytes returnData;
    }

    event AddMember(address guest);
    event RemoveMember(address guest);

    event SetName(string);
    event SetContact(string);
    event SetProfile(address erc721token, uint tokenId, address who);

    //
    // game state and immutables
    //

    EnumerableSet.AddressSet internal members;

    /// @dev The guild's name
    string public name;
    /// @dev The guild's contact info
    string public contact;
    /// @dev The guild's profile picture (plus whatever metadata)
    IERC721 public erc721ProfileToken;
    uint public erc721ProfileId;

    //
    // non-game state and immutables
    //

    /// @dev A contract used to clone contracts
    CloneFactory private immutable cloneFactory;
    /// @dev This contract has been initialized
    bool private initialized;
    /// @dev The original address of this contract
    address private immutable original;
    
    //
    // Setup functions
    //

    /// @notice a mostly empty constructor. use createNewGuild to actually make a place.
    constructor(CloneFactory _cloneFactory) {
        // non-game immutables
        cloneFactory = _cloneFactory;
        // save this address in the bytecode so that we can check for delegatecalls
        original = address(this);
    }

    function initialize(address owner, address[] calldata _members) external {
        require(address(this) != original, "!delegatecall");
        require(!initialized, "!initialize");

        initialized = true;

        Owned.initialize(owner);

        uint membersLength = _members.length;
        for (uint i = 1; i < membersLength; i++) {
            members.add(_members[i]);
        }
    }
    
    function newGuild(address _owner, address[] calldata _members, bytes32 salt) external returns (address guild) {
        require(address(this) == original, "!original");

        guild = cloneFactory.cloneTarget(address(this), salt);

        Guild(guild).initialize(_owner, _members);
    }

    //
    // Primary functions
    //

    /// @notice Play a blockchain game by combining one or more transactions
    function play(Call[] memory calls) authSender external returns (bytes[] memory returnData) {
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
    
    //
    // Profile functions
    //

    function profile() external view returns (address player, string memory, string memory, address, uint) {
        return (player, name, contact, address(erc721ProfileToken), erc721ProfileId);
    }

    function setName(string calldata _name) authSender external {
        name = _name;

        emit SetName(_name);
    }

    function setContact(string calldata _contact) authSender external {
        contact = _contact;

        emit SetContact(_contact);
    }

    function setProfile(IERC721 erc721Token, uint erc721TokenId) authSender external {
        address profileOwner = erc721Token.ownerOf(erc721TokenId);
        if (profileOwner != address(this)) {
            revert NotAuthorized(address(this), profileOwner);
        }

        erc721ProfileToken = erc721Token;
        erc721ProfileId = erc721TokenId;

        emit SetProfile(address(erc721Token), erc721TokenId, msg.sender);
    }

    /// @notice if ownership changed, clear the profile NFT
    function clearProfile() external {
        if (erc721ProfileToken.ownerOf(erc721ProfileId) == address(this)) {
            revert ProfileValid();
        }

        erc721ProfileToken = IERC721(address(0));
        erc721ProfileId = 0;

        emit SetProfile(address(erc721ProfileToken), erc721ProfileId, msg.sender);
    }

    //
    // Token standards
    //

    /// @dev allow receiving ERC721 tokens
    function onERC721Received(address, address, uint256, bytes calldata) external pure returns(bytes4) {
        return this.onERC721Received.selector;
    }

    /// @dev allow receiving ERC1155 tokens
    function onERC1155Received(address, address, uint256, uint256, bytes calldata) external pure returns(bytes4) {
        return this.onERC1155Received.selector;
    }

    /// @dev allow batch receiving ERC1155 tokens
    function onERC1155BatchReceived(address, address, uint256[] calldata, uint256[] calldata, bytes calldata)
        external pure returns(bytes4)
    {
        return this.onERC1155BatchReceived.selector;
    }

    /// @dev support ERC165
    function supportsInterface(bytes4 interfaceID) external pure returns (bool) {
        return  interfaceID == 0x01ffc9a7 ||    // ERC-165 support
                interfaceID == 0x80ac58cd ||    // ERC-721 TokenReceiver support
                interfaceID == 0x4e2312e0       // ERC-1155 TokenReceiver support
        ;
    }
}
