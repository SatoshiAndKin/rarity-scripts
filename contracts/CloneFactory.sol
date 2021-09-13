// SPDX-License-Identifier: MPL-2.0
// TODO: needs a better name
pragma solidity 0.8.7;

import "@OpenZeppelin/proxy/Clones.sol";

/// @title Create clones of contracts and then call a function on them
contract CloneFactory {
    using Clones for address;

    event NewClone(address indexed clone, address indexed target, bytes32 salt);

    function cloneTarget(address target, bytes32 salt, bytes calldata initData)
        external payable returns (address clone)
    {
        bytes32 pepper;
        
        if (initData.length > 0) {
            pepper = keccak256(abi.encodePacked(salt, initData));
        } else{
            pepper = salt;
        }

        clone = target.cloneDeterministic(pepper);
        emit NewClone(clone, target, pepper);

        if (initData.length > 0) {
            (bool success, ) = target.call(abi.encodeWithSignature("initialize(bytes)", initData));
        }
    }
}
