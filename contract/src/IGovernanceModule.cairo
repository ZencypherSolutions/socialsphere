use starknet::ContractAddress;
use super::types::{Action, Proposal};

/// Interface that all governance modules must implement
/// This ensures modularity and future compatibility across different governance mechanisms
#[starknet::interface]
pub trait IGovernanceModule<TContractState> {
    /// Creates a new proposal in the governance system
    ///
    /// # Arguments
    /// * `proposer` - The address of the account creating the proposal
    /// * `proposal_cid` - Content ID pointing to the proposal metadata (IPFS hash)
    /// * `actions` - Span of actions to be executed if the proposal passes
    fn create_proposal(
        ref self: TContractState,
        proposer: ContractAddress,
        proposal_cid: felt252,
        actions: Span<Action>,
    );

    /// Casts a vote on a specific proposal
    ///
    /// # Arguments
    /// * `voter` - The address of the account casting the vote
    /// * `proposal_id` - Unique identifier of the proposal
    /// * `vote` - Vote type: 0 = Against, 1 = For, 2 = Abstain
    fn cast_vote(ref self: TContractState, voter: ContractAddress, proposal_id: u256, vote: u8);

    /// Executes a proposal that has passed voting
    ///
    /// # Arguments
    /// * `proposal_id` - Unique identifier of the proposal to execute
    fn execute_proposal(ref self: TContractState, proposal_id: u256);

    /// Retrieves the full proposal data
    ///
    /// # Arguments
    /// * `proposal_id` - Unique identifier of the proposal
    ///
    /// # Returns
    /// Complete proposal struct with all metadata and current state
    fn get_proposal(self: @TContractState, proposal_id: u256) -> Proposal;

    /// Gets the current state of a proposal
    ///
    /// # Arguments
    /// * `proposal_id` - Unique identifier of the proposal
    ///
    /// # Returns
    /// Current state as u8: 0=Pending, 1=Active, 2=Succeeded, 3=Defeated, 4=Executed
    fn get_proposal_state(self: @TContractState, proposal_id: u256) -> u8;
}
