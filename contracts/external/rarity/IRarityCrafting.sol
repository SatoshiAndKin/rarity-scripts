// SPDX-License-Identifier: MPL-2.0
pragma solidity 0.8.7;

interface IRarityCrafting {
    event Crafted(
        address indexed owner,
        uint check,
        uint summoner,
        uint base_type,
        uint item_type,
        uint gold,
        uint craft_i
    );

    struct item {
        uint8 base_type;
        uint8 item_type;
        uint32 crafted;
        uint crafter;
    }

    function next_item() external returns(uint);
    function name() external returns (string memory);
    function symbol() external returns (string memory);
    // notice the spelling mistake
    function SUMMMONER_ID() external pure returns (uint);
    function get_goods_dc() external pure returns (uint dc);
    function get_armor_dc(uint _item_id) external pure returns (uint dc);
    function get_weapon_dc(uint _item_id) external pure returns (uint dc);
    function get_dc(uint _base_type, uint _item_id) external pure returns (uint dc);
    function get_item_cost(uint _base_type, uint _item_type) external pure returns (uint cost);
    function modifier_for_attribute(uint _attribute) external pure returns (int _modifier);
    function craft_skillcheck(uint _summoner, uint _dc) external view returns (bool crafted, int check);
    function isValid(uint _base_type, uint _item_type) external pure returns (bool);
    function simulate(
        uint _summoner,
        uint _base_type,
        uint _item_type,
        uint _crafting_materials
    ) external view returns (
        bool crafted,
        int check,
        uint cost,
        uint dc
    );
    function craft(uint _summoner, uint8 _base_type, uint8 _item_type, uint _crafting_materials) external;
    function items(uint) external returns(item memory);
    function get_type(uint _type_id) external pure returns (string memory _type);
    function tokenURI(uint _item) external view returns (string memory uri);
    function get_token_uri_goods(uint _item) external view returns (string memory output);
    function get_token_uri_armor(uint _item) external view returns (string memory output);
    function get_token_uri_weapon(uint _item) external view returns (string memory output);
}
