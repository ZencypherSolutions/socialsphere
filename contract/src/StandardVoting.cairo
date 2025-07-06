use starknet::ContractAddress;
use starknet::class_hash::ClassHash;
use starknet::Array;

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
    pub actions: Array,
}

#[starknet::contract]
pub mod StandardVoting {
    use super::Proposal;
    use starknet::Array;

    #[starknet::storage]
    struct Storage {
        proposals: LegacyMap<u256, Proposal>,
        proposal_count: u256,
        has_voted: LegacyMap<(u256, ContractAddress), bool>,
        voting_period: u64,
        quorum_percentage: u8,
        passing_threshold_percentage: u8,
    }

    #[constructor]
    fn constructor(ref self: ContractState, voting_period: u64, quorum_percentage: u8) {
        self.voting_period.write(voting_period);
        self.quorum_percentage.write(quorum_percentage);
    }
}