// DAO builder acts as the factory contract to initialize a new DAO where a new DAO Core contract is
// deployed.
// Anyone can call this contract to instantiate a new DAO and sub-committee/manager roles can be
// assigned by the DAO Owner in the DAO Core contract.
// DAO builder is the hub for inspecting overall and individual profile of deployed DAOs.

use starknet::class_hash::ClassHash;
#[starknet::interface]
trait IDaoBuilder<TContractState> {
    // Creates a new DAO. This creates a minimum implementation of a DAO.
    fn create_dao(ref self: TContractState, name: felt252, description: felt252, quorum: felt252);

    // Get total number of DAOs in existence.
    fn get_dao_count(self: @TContractState) -> felt252;

    // Pick one implementation for fetching details of a given DAO.
    fn get_dao_by_index(self: @TContractState, index: felt252) -> felt252;
    fn get_dao_by_address(self: @TContractState, address: felt252) -> felt252;

    // Temporary pauses/unpauses creation of new DAOs. Only the Core Team or the deployer of
    // dao_builder can call these functions.
    fn pause_creation(ref self: TContractState) -> bool;
    fn resume_creation(ref self: TContractState) -> bool;

    // This function can be called to update the DAO configuration of an existing DAO. Only admin of
    // the DAO can call this function.
    fn update_dao_configuration(ref self: TContractState, class_hash: ClassHash);
}

