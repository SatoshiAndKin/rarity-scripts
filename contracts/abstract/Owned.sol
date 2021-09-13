// SPDX-License-Identifier: MPL-2.0
/**

    A rudimentary guild contract. Any member can steal everything!

    More advanced authentication could be done by having the leader be a timelocked multisig
    and the members be limited smart contracts.

 */
pragma solidity 0.8.7;

import "@OpenZeppelin/utils/structs/EnumerableSet.sol";

error NotAuthorized(address needed, address found);


/// @title A NFT-owning contract for playing blockchain games
/// @author Bryan Stitt <bryan@satoshiandkin.com>
contract Owned {
    event HandOffOwnership(address owner, address nextOwner);
    event ReceiveOwnership(address oldOwner, address owner);

    constructor(address _owner) {
        owner = _owner;
    }

    modifier auth() {
        if (msg.sender != owner || !guildPlayers.contains(msg.sender)) {
            revert NotAuthorized(owner, msg.sender);
        }
        _;
    }

    /// @dev Begin the process of transferring ownership of this contract
    /// @dev call with `address(0)` to cancel
    function handOffOwnership(address _nextOwner) auth external {
        nextOwner = _nextOwner;

        emit HandOffOwnership(owner, _nextOwner);
    }

    /// @dev Complete the process of transferring ownership of this contract
    function receiveOwership() external {
        // like `auth` but check nextOwner
        if (msg.sender != nextOwner) {
            revert NotAuthorized(nextOwner, msg.sender);
        }

        // TODO: timelock?

        emit ReceiveOwnership(owner, nextOwner);

        owner = nextOwner;
        nextOwner = address(0);
    }
}
