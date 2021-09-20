// SPDX-License-Identifier: MPL-2.0
pragma solidity 0.8.7;

interface IRarityCraftMaterials {
    function approve(uint from, uint spender, uint amount) external returns (bool);
    function transfer(uint from, uint to, uint amount) external returns (bool);
}
