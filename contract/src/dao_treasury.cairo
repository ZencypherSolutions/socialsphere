use starknet::ContractAddress;
use starknet::{get_caller_address, get_contract_address}; 
use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
use core::traits::Into;
use core::num::traits::Zero;
use core::integer::u256;

#[starknet::interface]
trait IERC20<TContractState> {
    fn balance_of(self: @TContractState, account: ContractAddress) -> u256;
}

#[starknet::interface]
trait ITreasury<TContractState> {
    fn set_governance_module(ref self: TContractState, new_governance_module: ContractAddress);
    fn get_balance(self: @TContractState, token_address: ContractAddress) -> u256;
}

#[starknet::contract]
mod Treasury {
    use super::*;
    use starknet::get_block_timestamp;

    #[storage]
    struct Storage {
        governance_module: ContractAddress,
        admin: ContractAddress,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        GovernanceModuleUpdated: GovernanceModuleUpdated
    }

    #[derive(Drop, starknet::Event)]
    struct GovernanceModuleUpdated {
        new_module: ContractAddress,
        timestamp: u64
    }

    #[constructor]
    fn constructor(ref self: ContractState, admin: ContractAddress, initial_governance: ContractAddress) {
        self.admin.write(admin);
        self.governance_module.write(initial_governance);
    }

    #[abi(embed_v0)]
    impl TreasuryImpl of ITreasury<ContractState> {
        /// Updates the governance module address
        /// 
        /// # Arguments
        /// * `new_governance_module` - Address of new governance contract
        ///
        /// # Security
        /// - Only callable by admin
        /// - Changing governance module gives control over treasury funds
        /// - Should follow DAO governance procedures
        fn set_governance_module(ref self: ContractState, new_governance_module: ContractAddress) {
            self._only_admin();
            assert!(!new_governance_module.is_zero(), "Zero address not allowed");
            self.governance_module.write(new_governance_module);
            self.emit(Event::GovernanceModuleUpdated(GovernanceModuleUpdated {
                new_module: new_governance_module,
                timestamp: get_block_timestamp()
            }));
        }

        /// Returns the balance of specified token
        /// 
        /// # Arguments
        /// * `token_address` - Token contract address (zero for STRK)
        fn get_balance(self: @ContractState, token_address: ContractAddress) -> u256 {

            IERC20Dispatcher { contract_address: token_address }
                .balance_of(get_contract_address())
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn _only_admin(self: @ContractState) {
            let caller = get_caller_address();
            assert!(caller == self.admin.read(), "Caller not admin");
        }
    }
}