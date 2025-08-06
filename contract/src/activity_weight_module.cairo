use starknet::storage::{
    Map, StorageMapReadAccess, StorageMapWriteAccess, StoragePointerReadAccess,
    StoragePointerWriteAccess,
};
use starknet::{ContractAddress, get_block_timestamp, get_caller_address};

// Interface for vote weight modules
#[starknet::interface]
pub trait IVoteWeightModule<TContractState> {
    /// Returns the voting weight for a given voter address
    fn get_weight(self: @TContractState, voter: ContractAddress) -> u128;

    /// Sets the activity window (admin only)
    fn set_activity_window(ref self: TContractState, new_window: u64);

    /// Gets the current activity window
    fn get_activity_window(self: @TContractState) -> u64;

    /// Updates activity score for a voter (can be called by authorized contracts)
    fn update_activity_score(ref self: TContractState, voter: ContractAddress, new_score: u128);
}

#[starknet::contract]
pub mod ActivityWeightModule {
    use core::num::traits::Zero;
    use super::*;

    #[storage]
    struct Storage {
        admin: ContractAddress,
        activity_window: u64, // Window in seconds for activity tracking
        activity_scores: Map<ContractAddress, u128> // Cached activity scores
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        ActivityWindowUpdated: ActivityWindowUpdated,
        ActivityScoreUpdated: ActivityScoreUpdated,
    }

    #[derive(Drop, starknet::Event)]
    pub struct ActivityWindowUpdated {
        pub old_window: u64,
        pub new_window: u64,
        pub timestamp: u64,
    }

    #[derive(Drop, starknet::Event)]
    pub struct ActivityScoreUpdated {
        pub voter: ContractAddress,
        pub old_score: u128,
        pub new_score: u128,
        pub timestamp: u64,
    }

    #[constructor]
    fn constructor(ref self: ContractState, admin: ContractAddress, initial_window: u64) {
        assert!(!admin.is_zero(), "Admin cannot be zero address");
        self.admin.write(admin);
        self.activity_window.write(initial_window);
    }

    #[abi(embed_v0)]
    impl ActivityWeightModuleImpl of super::IVoteWeightModule<ContractState> {
        /// Returns the cached activity score for the voter
        /// This represents their on-chain activity over the sliding window
        fn get_weight(self: @ContractState, voter: ContractAddress) -> u128 {
            self.activity_scores.read(voter)
        }

        /// Admin function to set the activity window
        /// The window defines how far back to look for activity
        fn set_activity_window(ref self: ContractState, new_window: u64) {
            self._only_admin();
            let old_window = self.activity_window.read();
            self.activity_window.write(new_window);

            self
                .emit(
                    Event::ActivityWindowUpdated(
                        ActivityWindowUpdated {
                            old_window, new_window, timestamp: get_block_timestamp(),
                        },
                    ),
                );
        }

        /// Returns the current activity window in seconds
        fn get_activity_window(self: @ContractState) -> u64 {
            self.activity_window.read()
        }

        /// Updates the activity score for a voter
        /// This would typically be called by an oracle or indexer contract
        /// that monitors on-chain activity
        fn update_activity_score(ref self: ContractState, voter: ContractAddress, new_score: u128) {
            self._only_admin(); // For now, only admin can update scores
            // In production, you might want to allow specific authorized contracts

            let old_score = self.activity_scores.read(voter);
            self.activity_scores.write(voter, new_score);

            self
                .emit(
                    Event::ActivityScoreUpdated(
                        ActivityScoreUpdated {
                            voter, old_score, new_score, timestamp: get_block_timestamp(),
                        },
                    ),
                );
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn _only_admin(self: @ContractState) {
            let caller = get_caller_address();
            assert!(caller == self.admin.read(), "Caller is not admin");
        }
    }
}
