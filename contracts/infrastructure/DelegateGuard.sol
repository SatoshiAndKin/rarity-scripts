// SPDX-License-Identifier: MPL-2.0
pragma solidity 0.8.7;

/// @title checks for DELEGATECALL or CALL.
/// @dev use to make sure you are called (or not called) by a proxy
abstract contract DelegateGuard {

    /// @dev The original address of this contract
    address internal immutable original;

    /// @notice save this address in the bytecode so that we can check for delegatecalls
    constructor() {
        original = address(this);
    }

    /// @dev Require being CALLed by a contract or EOA
    function requireCallOriginal() internal view {
        require(original == address(this), "!call");
    }

    /// @dev Require being DELEGATECALLed by a proxy contract
    function requireDelegateCall() internal view {
        require(original != address(this), "!delegatecall");
    }
}
