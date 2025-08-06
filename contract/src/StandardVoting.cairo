use starknet::ContractAddress;

// Proposal structure 
#[derive(Copy, Drop, Serde, starknet::Store)]
pub struct Proposal {
    pub id: u256,
    pub proposer: ContractAddress,
    pub cid: felt252,
    pub vote_start_time: u64,
    pub vote_end_time: u64,
    pub for_votes: u256,
    pub against_votes: u256,
    pub abstain_votes: u256,
    pub is_executed: bool,
}

#[starknet::interface]
pub trait IGovernanceModule<TContractState> {
    fn create_proposal(
        ref self: TContractState,
        proposer: ContractAddress,
        cid: felt252,
    ) -> u256;
}

#[starknet::contract]
pub mod StandardVoting {
    use super::{Proposal, IGovernanceModule};
    use starknet::{ContractAddress, get_block_timestamp, get_caller_address};
    use starknet::storage::{
        Map, StorageMapWriteAccess, StoragePointerReadAccess,
        StoragePointerWriteAccess,
    };

    // Storage for the StandardVoting contract
    #[storage]
    struct Storage {
        proposals: Map<u256, Proposal>,
        proposal_count: u256,
        has_voted: Map<(u256, ContractAddress), bool>,
        voting_period: u64,
        quorum_percentage: u8,
        passing_threshold_percentage: u8,
        dao_core: ContractAddress, // Reference to DAOCore contract for member validation
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        ProposalCreated: ProposalCreated,
    }

    #[derive(Drop, starknet::Event)]
    pub struct ProposalCreated {
        #[key]
        pub proposal_id: u256,
        #[key]
        pub proposer: ContractAddress,
        pub cid: felt252,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState, 
        voting_period: u64, 
        quorum_percentage: u8,
        dao_core: ContractAddress,
    ) {
        self.voting_period.write(voting_period);
        self.quorum_percentage.write(quorum_percentage);
        self.dao_core.write(dao_core);
    }

    #[abi(embed_v0)]
    impl GovernanceModuleImpl of IGovernanceModule<ContractState> {
        fn create_proposal(
            ref self: ContractState,
            proposer: ContractAddress,
            cid: felt252,
        ) -> u256 {
            // For now, just check that the caller is the proposer
            let caller = get_caller_address();
            assert!(caller == proposer, "Caller must be the proposer");
            
            // Get current block timestamp
            let current_time = get_block_timestamp();
            
            // Calculate vote end time based on voting period
            let vote_end_time = current_time + self.voting_period.read();
            
            // Get next proposal ID and increment counter
            let proposal_id = self.proposal_count.read();
            self.proposal_count.write(proposal_id + 1);
            
            // Create new proposal
            let proposal = Proposal {
                id: proposal_id,
                proposer,
                cid,
                vote_start_time: current_time,
                vote_end_time,
                for_votes: 0,
                against_votes: 0,
                abstain_votes: 0,
                is_executed: false,
            };
            
            // Store the proposal
            self.proposals.write(proposal_id, proposal);
            
            // Emit ProposalCreated event
            self.emit(Event::ProposalCreated(ProposalCreated {
                proposal_id,
                proposer,
                cid,
            }));
            
            proposal_id
        }
    }

}