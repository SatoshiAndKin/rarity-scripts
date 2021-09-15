// SPDX-License-Identifier: MPL-2.0
pragma solidity 0.8.7;

import {CloneFactory} from "contracts/infrastructure/CloneFactory.sol";
import {DelegateGuard} from "contracts/infrastructure/DelegateGuard.sol";

/// @title checks for DELEGATECALL or CALL.
/// @dev use to make sure you are called (or not called) by a proxy
abstract contract Cloneable is DelegateGuard {

    /// @dev A contract used to clone contracts
    CloneFactory internal immutable cloneFactory;
    
    constructor(CloneFactory _cloneFactory) {
        cloneFactory = _cloneFactory;
    }
}
