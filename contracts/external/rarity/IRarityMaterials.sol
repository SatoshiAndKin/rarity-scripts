// SPDX-License-Identifier: MPL-2.0
pragma solidity 0.8.7;

interface IRarityMaterials {
    function approve(uint from, uint spender, uint amount) external returns (bool);
    function transfer(uint from, uint to, uint amount) external returns (bool);

    function scout(uint _summoner) external view returns (uint reward);
    function adventure(uint _summoner) external returns (uint reward);

    function adventurers_log(uint _summoner) external view returns (uint);
}
