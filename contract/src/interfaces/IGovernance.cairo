use starknet::ContractAddress;
use contract::types::proposal::{Action, Proposal, ProposalState};

/// Interface that all governance modules must implement to be compatible with the SocialSphere platform.
#[starknet::interface]
trait IGovernanceModule<TContractState> {
    /// Creates a new proposal in the governance module
    /// # Arguments
    /// * `proposer` - The address of the account creating the proposal
    /// * `proposal_cid` - Proposal CID
    /// * `actions` - Array of actions to be executed if the proposal passes
    fn create_proposal(
        ref self: TContractState,
        proposer: ContractAddress,
        proposal_cid: felt252,
        actions: Span<Action>,
    );

    /// Casts a vote on a proposal
    /// # Arguments
    /// * `voter` - The address of the account casting the vote
    /// * `proposal_id` - The ID of the proposal to vote on
    /// * `vote` - The vote value (0 = Against, 1 = For, 2 = Abstain)
    fn cast_vote(
        ref self: TContractState,
        voter: ContractAddress,
        proposal_id: u256,
        vote: u8
    );

    /// Executes a successful proposal
    /// # Arguments
    /// * `proposal_id` - The ID of the proposal to execute
    /// # Panics
    /// * If the proposal is not in Succeeded state
    /// * If the execution of any action fails
    /// * If the proposal has already been executed
    fn execute_proposal(ref self: TContractState, proposal_id: u256);

    /// Retrieves the full proposal data for a given proposal ID
    /// # Arguments
    /// * `proposal_id` - The ID of the proposal to query
    /// # Returns
    /// * `Proposal` - The full proposal data
    fn get_proposal(self: @TContractState, proposal_id: u256) -> Proposal;

    /// Gets the current state of a proposal
    /// # Arguments
    /// * `proposal_id` - The ID of the proposal to query
    /// # Returns
    /// * `ProposalState` - The current state of the proposal
    fn get_proposal_state(self: @TContractState, proposal_id: u256) -> ProposalState;
} 