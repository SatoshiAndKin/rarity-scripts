// SPDX-License-Identifier: MPL-2.0
pragma solidity 0.8.7;

import {IERC721} from "./external/IERC721.sol";

error NotAuthorized(address needed, address found);
error CallReverted(address target, bool delegate, bytes data, bytes errorData);
error ProfileValid();

/// @title State variables for a GameAccount
/// @dev keep the state here so making contracts that delegatecall to change state are easy to write
abstract contract GameAccountStorage {
    /// @dev the contract owner
    address internal player;
    /// @dev the next owner (if a hand off is in progress)
    address internal nextPlayer;

    /// @dev The account's name
    string internal name;
    /// @dev The account's contact info
    string internal contact;
    /// @dev The account's profile picture (plus whatever metadata)
    IERC721 internal erc721ProfileToken;
    uint internal erc721ProfileId;
}

/// @title A NFT-owning contract for playing blockchain games
/// @author Bryan Stitt <bryan@satoshiandkin.com>
contract GameAccount is GameAccountStorage {

    struct Call {
        address target;
        bool delegate;
        bytes data;
    }
    struct Result {
        bool success;
        bytes returnData;
    }

    event HandOffOwnership(address player, address nextPlayer);
    event ReceiveOwnership(address oldPlayer, address player);
    event SetName(string);
    event SetContact(string);
    event SetProfile(address erc721token, uint tokenId, address who);

    //
    // Primary functions
    //

    constructor(address _player) {
        // TODO: delegatecall proxy instead of per-player contract

        // all the state is in GameAccountStorage
        player = _player;
    }

    modifier auth() {
        if (msg.sender != player) {
            revert NotAuthorized(player, msg.sender);
        }
        _;
    }

    /// @notice Play a blockchhain game by combining one or more transactions
    function play(Call[] memory calls) auth external returns (bytes[] memory returnData) {
        returnData = new bytes[](calls.length);
        uint callsLength = calls.length;
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

    function getNextPlayer() external view returns (address) {
        return nextPlayer;
    }

    function profile() external view returns (address player, string memory, string memory, address, uint) {
        return (player, name, contact, address(erc721ProfileToken), erc721ProfileId);
    }

    function setName(string calldata _name) auth external {
        name = _name;

        emit SetName(_name);
    }

    function setContact(string calldata _contact) auth external {
        contact = _contact;

        emit SetContact(_contact);
    }

    function setProfile(IERC721 erc721Token, uint erc721TokenId) auth external {
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
    function onERC1155BatchReceived(address, address, uint256[] calldata, uint256[] calldata, bytes calldata) external pure returns(bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    /// @dev support ERC165
    function supportsInterface(bytes4 interfaceID) external pure returns (bool) {
        return  interfaceID == 0x01ffc9a7 ||    // ERC-165 support (i.e. `bytes4(keccak256('supportsInterface(bytes4)'))`).
                interfaceID == 0x80ac58cd ||    // ERC-721 support
                interfaceID == 0x4e2312e0       // ERC-1155 `ERC1155TokenReceiver` support (i.e. `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)")) ^ bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`).
        ;
    }

    //
    // Ownership
    //

    /// @dev Begin the process of transferring ownership of this contract
    /// @dev call with `address(0)` to cancel
    function handOffOwnership(address _nextPlayer) auth external {
        nextPlayer = _nextPlayer;

        emit HandOffOwnership(player, _nextPlayer);
    }

    /// @dev Complete the process of transferring ownership of this contract
    function receiveOwership() external {
        // like `auth` but check nextPlayer
        if (msg.sender != nextPlayer) {
            revert NotAuthorized(nextPlayer, msg.sender);
        }

        emit ReceiveOwnership(player, nextPlayer);

        player = nextPlayer;
        nextPlayer = address(0);
    }
}
