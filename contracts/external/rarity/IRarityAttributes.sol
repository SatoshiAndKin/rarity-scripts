// SPDX-License-Identifier: MPL-2.0
pragma solidity 0.8.7;

interface IRarityAttributes {

    struct ability_score {
        uint32 strength;
        uint32 dexterity;
        uint32 constitution;
        uint32 intelligence;
        uint32 wisdom;
        uint32 charisma;
    }

    event Created(address indexed creator, uint summoner, uint32 strength, uint32 dexterity, uint32 constitution, uint32 intelligence, uint32 wisdom, uint32 charisma);
    event Leveled(address indexed leveler, uint summoner, uint32 strength, uint32 dexterity, uint32 constitution, uint32 intelligence, uint32 wisdom, uint32 charisma);
    
    function ability_scores(uint) external returns(ability_score memory);
    function level_points_spent(uint) external returns(uint);
    function character_created(uint) external returns(bool);
    function point_buy(uint _summoner, uint32 _str, uint32 _dex, uint32 _const, uint32 _int, uint32 _wis, uint32 _cha) external;
    function calculate_point_buy(uint _str, uint _dex, uint _const, uint _int, uint _wis, uint _cha) external pure returns (uint);
    function calc(uint score) external pure returns (uint);
    function increase_strength(uint _summoner) external;
    function increase_dexterity(uint _summoner) external;    
    function increase_constitution(uint _summoner) external;
    function increase_intelligence(uint _summoner) external;
    function increase_wisdom(uint _summoner) external;
    function increase_charisma(uint _summoner) external;    
    function abilities_by_level(uint current_level) external pure returns (uint);
    function tokenURI(uint256 _summoner) external view returns (string memory);
}
