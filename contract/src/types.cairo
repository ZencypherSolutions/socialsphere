use starknet::ContractAddress;

/// Example usage of ProposalState conversions and interface interactions:
///
/// ```cairo
/// // The interface returns u8 directly from get_proposal_state()
/// let state_u8: u8 = governance_module.get_proposal_state(proposal_id); // Returns 0-4
///
/// // Convert u8 to ProposalState enum for pattern matching
/// let state_option: Option<ProposalState> = state_u8.try_into();
/// match state_option {
///     Option::Some(ProposalState::Active) => {
///         // Handle active proposal
///     },
///     Option::Some(ProposalState::Succeeded) => {
///         // Handle succeeded proposal
///     },
///     Option::None => {
///         // Invalid state value
///     }
/// }
///
/// // Convert ProposalState to u8 when storing in Proposal struct
/// let state = ProposalState::Active;
/// let proposal = Proposal {
///     // ... other fields ...
///     state: state.into(), // Converts to u8 (1)
///     // ... other fields ...
/// };
/// ```

/// Represents the state of a governance proposal
#[derive(Copy, Drop, Serde, starknet::Store, PartialEq)]
pub enum ProposalState {
    /// Proposal is waiting to become active
    Pending,
    /// Proposal is active for voting
    Active,
    /// Proposal succeeded and can be executed
    Succeeded,
    /// Proposal was defeated in voting
    Defeated,
    /// Proposal was executed
    #[default]
    Executed,
}

/// Implementation to convert ProposalState to u8
impl ProposalStateIntoU8 of Into<ProposalState, u8> {
    fn into(self: ProposalState) -> u8 {
        match self {
            ProposalState::Pending => 0,
            ProposalState::Active => 1,
            ProposalState::Succeeded => 2,
            ProposalState::Defeated => 3,
            ProposalState::Executed => 4,
        }
    }
}

/// Implementation to convert u8 to ProposalState
impl U8TryIntoProposalState of TryInto<u8, ProposalState> {
    fn try_into(self: u8) -> Option<ProposalState> {
        match self {
            0 => Option::Some(ProposalState::Pending),
            1 => Option::Some(ProposalState::Active),
            2 => Option::Some(ProposalState::Succeeded),
            3 => Option::Some(ProposalState::Defeated),
            4 => Option::Some(ProposalState::Executed),
            _ => Option::None,
        }
    }
}

/// Represents an action to be executed as part of a proposal
#[derive(Drop, Serde)]
pub struct Action {
    /// The target contract address to call
    pub target: ContractAddress,
    /// The selector of the function to call
    pub selector: felt252,
    /// The calldata to pass to the function
    pub calldata: Array<felt252>,
}

/// Represents a governance proposal
#[derive(Drop, Serde)]
pub struct Proposal {
    pub id: u256,
    pub proposer: ContractAddress,
    pub cid: felt252,
    pub vote_start_time: u64,
    pub vote_end_time: u64,
    pub for_votes: u256,
    pub against_votes: u256,
    pub abstain_votes: u256,
    pub state: u8, // 0=Pending, 1=Active, 2=Succeeded, 3=Defeated, 4=Executed
    pub is_executed: bool,
    pub actions: Span<Action>,
}

