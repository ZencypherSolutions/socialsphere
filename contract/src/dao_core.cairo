// The DAO Core contract manages individual DAOs with role specific functions. 
// This contract has the option to be connected with the governance contract by passing the governanc contract address to the constructor of dao_core. 

use starknet::{ContractAddress};

#[starknet::interface]
trait IDaoCore<TContractState> {

    // Remove a member from the DAO, returns true if the member was successfully removed. 
    // This function can only be called by the DAO Owner or sub-committee members. 
    fn remove_member(ref self: TContractState, member_address: felt252) -> bool;

    // Add a member to the DAO, returns true if the member was successfully added.
    // This function can only be called by the DAO Owner or sub-committee members. 
    fn add_member(ref self: TContractState, member_address: felt252, tier: u8) -> bool;

    // Get the role of a member. 
    fn get_member_role(self: @TContractState, member_address: felt252) -> felt252;
    // Get the total number of members in the DAO. 
    fn get_members_count(self: @TContractState) -> felt252;
    // Get the owner of the DAO.
    fn get_owner(self: @TContractState) -> ContractAddress;

    // Assign a role to a member. 
    // This function can only be called by the DAO Owner or sub-committee members. 
    // For role argument each number represents a role, by default, a new member is assigned asGeneral Member:
    // 1 - DAO Owner, 2 - Sub-Committee, 3 - General Member
    fn assign_role(ref self: TContractState, member_address: felt252, role: u8);

    // Transfer the ownership of the DAO to a new owner. 
    // This function can only be called by the DAO Owner. 
    fn transfer_ownership(ref self: TContractState, new_owner: ContractAddress); 
}
