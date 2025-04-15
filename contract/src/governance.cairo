// Governance contract manages proposals and votes for a given DAO. 
// Given that this contract is the basis of the governance system, this contract can always be modified to add additional governance functions with components.

#[starknet::interface]
trait IGovernance<TContractState> {

    // Creates a proposal, anyone that is a member of the DAO can create a proposal. 
    fn create_proposal(ref self: TContractState, description: felt252) -> u32;

    // Cancel a proposal, only the DAO Owner or proposed member can cancel a proposal. 
    fn cancel_proposal(ref self: TContractState, proposal_id: felt252) -> bool;

    // Execute the proposal, once it reaches the quorum at the end of the voting period. 
    fn execute_proposal(ref self: TContractState, proposal_id: felt252) -> bool;

    // Vote on a proposal, returns true if the vote was successfully cast. 
    fn vote_on_proposal(ref self: TContractState, proposal_id: felt252, vote: felt252) -> bool;

    // Set the quorum of all proposals for this DAO. Only the DAO Owner or sub-committee members can call this function. There must be a cooldown period AND all proposals must be closed before the quorum can be changed. 
    fn set_quorum(ref self: TContractState, quorum: felt252, cooldown: felt252);
    
    // Get the Proposal details which will return a Proposal struct. 
    // fn get_proposal(self: @TContractState, proposal_id: felt252) -> Proposal; 
    
}