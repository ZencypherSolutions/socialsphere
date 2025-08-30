use core::integer::u256;
use core::num::traits::Zero;
use core::traits::Into;
use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
use starknet::{ContractAddress, get_caller_address, get_contract_address};

#[starknet::interface]
trait IERC20<TContractState> {
    fn balance_of(self: @TContractState, account: ContractAddress) -> u256;
    fn transfer(ref self: TContractState, recipient: ContractAddress, amount: u256) -> bool;
}

#[starknet::interface]
trait ITreasury<TContractState> {
    fn set_governance_module(ref self: TContractState, new_governance_module: ContractAddress);
    fn get_balance(self: @TContractState, token_address: ContractAddress) -> u256;
    fn execute_transfer(
        ref self: TContractState,
        token_address: ContractAddress,
        recipient: ContractAddress,
        amount: u256,
    );
    fn execute_eth_transfer(ref self: TContractState, recipient: ContractAddress, amount: u256);
}

#[starknet::contract]
mod Treasury {
    use starknet:: get_block_timestamp;
    use super::*;

    #[storage]
    struct Storage {
        governance_module: ContractAddress,
        admin: ContractAddress,
        strk_token_adress: ContractAddress,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        GovernanceModuleUpdated: GovernanceModuleUpdated,
        FundsWithdrawn: FundsWithdrawn,
        DepositReceived: DepositReceived,
    }

    #[derive(Drop, starknet::Event)]
    struct GovernanceModuleUpdated {
        new_module: ContractAddress,
        timestamp: u64,
    }

    #[derive(Drop, starknet::Event)]
    struct FundsWithdrawn {
        token: ContractAddress,
        amount: u256,
        recipient: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct DepositReceived {
        sender: ContractAddress,
        amount: u256,
        timestamp: u64,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        admin: ContractAddress,
        initial_governance: ContractAddress,
        strk_token_adress: ContractAddress,
    ) {
        self.admin.write(admin);
        self.governance_module.write(initial_governance);
        self.strk_token_adress.write(strk_token_adress);
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
            self
                .emit(
                    Event::GovernanceModuleUpdated(
                        GovernanceModuleUpdated {
                            new_module: new_governance_module, timestamp: get_block_timestamp(),
                        },
                    ),
                );
        }

        /// Returns the balance of specified token
        ///
        /// # Arguments
        /// * `token_address` - Token contract address  (zero for STRK)
        fn get_balance(self: @ContractState, token_address: ContractAddress) -> u256 {
            IERC20Dispatcher { contract_address: token_address }.balance_of(get_contract_address())
        }

        /// Executes transfer of ERC-20 tokens from treasury
        ///
        /// # Arguments
        /// * `token_address` - Address of the ERC-20 token contract
        /// * `recipient` - Address to receive the tokens
        /// * `amount` - Amount of tokens to transfer
        ///
        /// # Security
        /// - Only callable by governance module
        fn execute_transfer(
            ref self: ContractState,
            token_address: ContractAddress,
            recipient: ContractAddress,
            amount: u256,
        ) {
            self._only_governance();
            assert!(!recipient.is_zero(), "RECIPIENT_ADDRESS_ZERO");
            assert!(!token_address.is_zero(), "TOKEN_ADDRESS_ZERO");
            assert!(amount > 0, "AMOUNT_ZERO");


            let current_balance = self.get_balance(token_address);
            assert!(current_balance >= amount, "INSUFFICIENT_BALANCE");


            let success = IERC20Dispatcher { contract_address: token_address }
                .transfer(recipient, amount);
            assert!(success, "TRANSFER_FAILED");

            self
                .emit(
                    Event::FundsWithdrawn(
                        FundsWithdrawn { token: token_address, amount, recipient },
                    ),
                );
        }

        /// Executes transfer of native STRK from treasury
        ///
        /// # Arguments
        /// * `recipient` - Address to receive the STRK
        /// * `amount` - Amount of STRK to transfer (in wei)
        ///
        /// # Security
        /// - Only callable by governance module
        fn execute_eth_transfer(ref self: ContractState, recipient: ContractAddress, amount: u256) {
            self._only_governance();
            let strk_address = self.strk_token_adress.read();
            assert!(!recipient.is_zero(), "RECIPIENT_ADDRESS_ZERO");
            assert!(amount > 0, "AMOUNT_ZERO");

        
            let current_strk_balance = self.get_balance(strk_address);
            assert!(current_strk_balance >= amount, "INSUFFICIENT_STRK_BALANCE");

   
            let success = IERC20Dispatcher { contract_address: strk_address }
                .transfer(recipient, amount);
            assert!(success, "STRK_TRANSFER_FAILED");
            self
                .emit(
                    Event::FundsWithdrawn(
                        FundsWithdrawn { token: strk_address, amount, recipient },
                    ),
                );
        }
    }

    /// Allow contract to accept STRK deposits
    #[l1_handler]
    fn deposit(ref self: ContractState, from_address: felt252, amount: u256) {
        let sender = get_caller_address();

        self
            .emit(
                Event::DepositReceived(
                    DepositReceived { sender, amount, timestamp: get_block_timestamp() },
                ),
            );
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn _only_admin(self: @ContractState) {
            let caller = get_caller_address();
            assert!(caller == self.admin.read(), "Caller not admin");
        }

        fn _only_governance(self: @ContractState) {
            let caller = get_caller_address();
            assert!(caller == self.governance_module.read(), "Caller not governance module");
        }
    }
}
