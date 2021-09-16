// SPDX-License-Identifier: MPL-2.0
/**

    A rudimentary guild contract. Any member can steal everything!

    More advanced authentication could be done by having the leader be a timelocked multisig
    and the members be limited smart contracts.

 */
pragma solidity 0.8.7;

import {Cloneable, CloneFactory} from "./Cloneable.sol";

import "contracts/infrastructure/Errors.sol";

abstract contract OwnedCloneable is Cloneable {

    address private __owner;
    address private __nextOwner;

    event HandOffOwnership(address owner, address nextOwner);
    event ReceiveOwnership(address oldOwner, address owner);

    constructor(CloneFactory _cloneFactory) Cloneable(_cloneFactory) {}

    /// @dev BE SURE TO CALL THIS IN YOUR "initialize" FUNCTION!
    function initialize(address _owner) internal {
        __owner = _owner;
    }

    /// @dev revert if the transaction sender is not the contract owner
    function requireOwnerSender() internal {
        if (msg.sender != __owner) {
            revert NotAuthorized(__owner, msg.sender);
        }
    }

    /// @dev Begin the process of transferring ownership of this contract
    /// @dev call with `address(0)` to cancel
    function handOffOwnership(address _nextOwner) external {
        requireOwnerSender();

        __nextOwner = _nextOwner;

        emit HandOffOwnership(__owner, _nextOwner);
    }

    function nextOwner() public returns (address) {
        return __nextOwner;
    }

    function owner() public returns (address) {
        return __owner;
    }

    /// @dev Complete the process of transferring ownership of this contract
    function receiveOwership() external {
        // like `authSender` but check msg.sender againt nextOwner instead of owner
        if (msg.sender != __nextOwner) {
            revert NotAuthorized(__nextOwner, msg.sender);
        }

        // TODO: timelock?

        emit ReceiveOwnership(__owner, __nextOwner);

        __owner = __nextOwner;
        __nextOwner = address(0);
    }
}
