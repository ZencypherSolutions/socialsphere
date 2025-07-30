use starknet::ContractAddress;

#[starknet::interface]
pub trait IVoteWeight<TContractState> {
    fn set_weight(ref self: TContractState, account: ContractAddress, weight: u128);
    fn bulk_set_weights(
        ref self: TContractState, accounts: Span<ContractAddress>, weights: Span<u128>,
    );
    fn get_weight(self: @TContractState, voter: ContractAddress) -> u128;
}

#[starknet::contract]
pub mod CustomFactor {
    use core::num::traits::Zero;
    use openzeppelin::access::accesscontrol::{AccessControlComponent, DEFAULT_ADMIN_ROLE};
    use openzeppelin::introspection::src5::SRC5Component;
    use starknet::ContractAddress;
    use starknet::storage::{
        Map, StoragePathEntry, StoragePointerReadAccess, StoragePointerWriteAccess,
    };

    component!(path: AccessControlComponent, storage: accesscontrol, event: AccessControlEvent);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);

    // AccessControl
    #[abi(embed_v0)]
    impl AccessControlImpl =
        AccessControlComponent::AccessControlImpl<ContractState>;
    impl AccessControlInternalImpl = AccessControlComponent::InternalImpl<ContractState>;

    // SRC5
    #[abi(embed_v0)]
    impl SRC5Impl = SRC5Component::SRC5Impl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        accesscontrol: AccessControlComponent::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
        weights: Map<ContractAddress, u128>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        #[flat]
        AccessControlEvent: AccessControlComponent::Event,
        #[flat]
        SRC5Event: SRC5Component::Event,
        WeightSet: WeightSet,
    }

    #[derive(Drop, starknet::Event)]
    pub struct WeightSet {
        pub account: ContractAddress,
        pub weight: u128,
    }

    #[abi(embed_v0)]
    impl VoteWeightImpl of super::IVoteWeight<ContractState> {
        fn set_weight(ref self: ContractState, account: ContractAddress, weight: u128) {
            // Admin only
            self.accesscontrol.assert_only_role(DEFAULT_ADMIN_ROLE);

            // Ensure the account is not zero
            assert(!account.is_zero(), 'Account cannot be zero');

            self.weights.entry(account).write(weight);
            self.emit(Event::WeightSet(WeightSet { account, weight }));
        }

        fn bulk_set_weights(
            ref self: ContractState, accounts: Span<ContractAddress>, weights: Span<u128>,
        ) {
            // Admin only
            self.accesscontrol.assert_only_role(DEFAULT_ADMIN_ROLE);

            let accounts_len = accounts.len();
            let weights_len = weights.len();

            // Ensure the accounts and weights are not empty
            assert(accounts_len > 0, 'Accounts cannot be empty');
            assert(weights_len > 0, 'Weights cannot be empty');

            // Ensure both spans have the same length
            assert(accounts_len == weights_len, 'Length mismatch');

            for i in 0..accounts_len {
                let account = *accounts[i];
                let weight = *weights[i];

                // Ensure the account is not zero
                assert(!account.is_zero(), 'Account cannot be zero');

                self.weights.entry(account).write(weight);
                self.emit(Event::WeightSet(WeightSet { account, weight }));
            }
        }

        fn get_weight(self: @ContractState, voter: ContractAddress) -> u128 {
            self.weights.entry(voter).read()
        }
    }

    #[constructor]
    fn constructor(ref self: ContractState, admin: ContractAddress) {
        assert!(!admin.is_zero(), "Admin address cannot be zero");
        self.accesscontrol.initializer();
        self.accesscontrol._grant_role(DEFAULT_ADMIN_ROLE, admin);
    }
}
