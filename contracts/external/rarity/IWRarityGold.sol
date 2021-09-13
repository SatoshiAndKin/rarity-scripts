// SPDX-License-Identifier: MPL-2.0
pragma solidity 0.8.7;

/// @title ERC-20 wrapping for Rarity Gold
interface IWrappedRarityGold {
    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed owner, address indexed spender, uint amount);

    function SUMMMONER_ID() external returns (uint);
    function rarity_interface() external returns (address);
    function rarity_gold_interface() external returns (address);

    function name() external returns (string memory);
    function symbol() external returns (string memory);
    function decimals() external returns (uint8);

    function totalSupply() external returns (uint);

    function allowance(address, address) external returns (uint);
    function balanceOf(address, uint) external returns (uint);

    function deposit(uint from, uint amount) external;
    function withdraw(uint to, uint amount) external;
    function approve(address spender, uint amount) external returns (bool);
    function transfer(address dst, uint amount) external returns (bool);
    function transferFrom(address src, address dst, uint amount) external returns (bool);
}
