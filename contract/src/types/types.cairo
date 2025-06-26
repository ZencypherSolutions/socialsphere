use starknet::ContractAddress;

/// Represents a single action to be executed when a proposal passes
#[derive(Drop, Serde)]
pub struct Action {
    /// The target contract address where the action will be executed
    target: ContractAddress,
    /// The selector of the function to be called
    selector: felt252,
    /// The calldata to be passed to the function
    calldata: Span<felt252>,
}

/// Represents the current state of a proposal
#[derive(Drop, Copy, Serde)]
pub enum ProposalState {
    /// Proposal is waiting to enter voting period
    Pending,
    /// Proposal is currently being voted on
    Active,
    /// Proposal has passed and can be executed
    Succeeded,
    /// Proposal has been rejected
    Defeated,
    /// Proposal has been executed
    Executed,
}

/// Represents a governance proposal
#[derive(Drop, Serde)]
pub struct Proposal {
    /// Unique identifier for the proposal
    id: u256,
    /// The address of the account that created the proposal
    proposer: ContractAddress,
    /// IPFS CID containing the proposal's description and metadata
    cid: felt252,
    /// Unix timestamp when voting begins
    vote_start_time: u64,
    /// Unix timestamp when voting ends
    vote_end_time: u64,
    /// Number of votes in favor of the proposal
    for_votes: u256,
    /// Number of votes against the proposal
    against_votes: u256,
    /// Number of abstain votes
    abstain_votes: u256,
    /// Whether the proposal has been executed
    is_executed: bool,
    /// The actions to be executed if the proposal passes
    actions: Array<Action>,
} 