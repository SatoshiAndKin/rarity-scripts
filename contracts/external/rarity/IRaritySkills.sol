// SPDX-License-Identifier: MPL-2.0
pragma solidity 0.8.7;

interface IRarityCodexSkills {
    function skill_by_id(uint) external view returns (
        uint id,
        string memory name,
        uint attribute_id,
        uint synergy,
        bool retry,
        bool armor_check_penalty,
        string memory check,
        string memory action
    );
}

interface IRaritySkills {

    function class_skills_by_name(uint _class) external view returns (string[] memory);

    function calculate_points_for_set(uint _class, uint8[36] memory _skills) external pure returns (uint points);

    function is_valid_set(uint _summoner, uint8[36] memory _skills) external view returns (bool);

    function class_skills(uint _class) external pure returns (bool[36] memory _skills);

    function modifier_for_attribute(uint _attribute) external pure returns (int _modifier);

    function skills_per_level(int _int, uint _class, uint _level) external pure returns (uint points);

    function base_per_class(uint _class) external pure returns (uint base);

    function skills(uint _class) external returns (uint8[36] memory);

    function get_skills(uint _summoner) external view returns (uint8[36] memory);

    function set_skills(uint _summoner, uint8[36] memory _skills) external;
}
