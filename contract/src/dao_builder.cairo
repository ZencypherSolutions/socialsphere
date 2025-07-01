// DAO builder acts as the factory contract to initialize a new DAO where a new DAO Core contract is
// deployed.
// Anyone can call this contract to instantiate a new DAO and sub-committee/manager roles can be
// assigned by the DAO Owner in the DAO Core contract.
// DAO builder is the hub for inspecting overall and individual profile of deployed DAOs.
use starknet::ContractAddress;
use starknet::class_hash::ClassHash;

#[derive(Copy, Drop, Serde, starknet::Store)]
pub struct DAO {
    pub index: u32,
    pub address: ContractAddress,
    pub deployer: ContractAddress,
    pub deployed_at: u64,
}

#[derive(Copy, Drop, Serde, Debug, PartialEq, starknet::Store)]
pub enum DAOCreationState {
    #[default]
    CREATIONRESUMED,
    CREATIONPAUSED,
}

#[starknet::interface]
pub trait IDaoBuilder<TContractState> {
    // Creates a new DAO. This creates a minimum implementation of a DAO.
    fn create_dao(
        ref self: TContractState,
        name: felt252,
        description: felt252,
        quorum: felt252,
        salt: felt252,
    ) -> ContractAddress;

    // Get total number of DAOs in existence.
    fn get_dao_count(self: @TContractState) -> u32;

    // Get the current creation state of the DAO builder.
    fn get_dao_creation_state(self: @TContractState) -> DAOCreationState;

    // Get the core hash of the DAO builder.
    fn get_core_hash(self: @TContractState) -> ClassHash;

    // Get the owner of the DAO builder.
    fn get_owner(self: @TContractState) -> ContractAddress;

    // Pick one implementation for fetching details of a given DAO.
    // fn get_dao_by_index(self: @TContractState, index: felt252) -> DAO;
    fn get_dao_by_address(self: @TContractState, address: ContractAddress) -> DAO;

    // Temporary pauses/unpauses creation of new DAOs. Only the Core Team or the deployer of
    // dao_builder can call these functions.
    // Temporary pauses/unpauses creation of new DAOs. Only the Core Team or the deployer of
    // dao_builder can call these functions.
    fn pause_creation(ref self: TContractState) -> bool;
    fn resume_creation(ref self: TContractState) -> bool;

    // This function can be called to update the DAO configuration of an existing DAO. Only admin of
    // the DAO can call this function.
    fn update_core_class_hash(
        ref self: TContractState, class_hash: ClassHash, dao_address: ContractAddress,
    );
}

#[starknet::contract]
pub mod DaoBuilder {
    use openzeppelin::access::ownable::OwnableComponent;
    use starknet::class_hash::ClassHash;
    use starknet::event::EventEmitter;
    use starknet::storage::{
        Map, StoragePathEntry, StoragePointerReadAccess, StoragePointerWriteAccess,
    };
    use starknet::syscalls::deploy_syscall;
    use starknet::{SyscallResultTrait, get_block_timestamp, get_caller_address};
    use super::{ContractAddress, DAO, DAOCreationState, IDaoBuilder};

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    #[abi(embed_v0)]
    impl OwnableMixinImpl = OwnableComponent::OwnableMixinImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    #[storage]
    pub struct Storage {
        #[substorage(v0)]
        pub ownable: OwnableComponent::Storage,
        pub core_hash: ClassHash,
        pub deployed_daos: Map<ContractAddress, DAO>, //map address of a dao to the dao properties
        pub dao_count: u32,
        pub dao_creation_state: DAOCreationState,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        #[flat]
        OwnableEvent: OwnableComponent::Event,
        DAODeployed: DAODeployed,
        CreationStateChanged: CreationStateChanged,
    }

    #[derive(Drop, starknet::Event)]
    pub struct DAODeployed {
        pub index: u32,
        pub deployer: ContractAddress,
        pub deployed_at: u64,
        pub dao_address: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    pub struct CreationStateChanged {
        pub new_state: DAOCreationState,
        pub state_changed_at: u64,
    }

    #[constructor]
    fn constructor(ref self: ContractState, initial_core_hash: ClassHash, owner: ContractAddress) {
        self.ownable.initializer(owner);
        self.dao_creation_state.write(DAOCreationState::CREATIONRESUMED);
        self.dao_count.write(0);
        self.core_hash.write(initial_core_hash);
    }

    #[abi(embed_v0)]
    pub impl DaoBuilderImpl of IDaoBuilder<ContractState> {
        // Creates a new DAO. This creates a minimum implementation of a DAO.
        // if necessary, add the admin to the arguments
        fn create_dao(
            ref self: ContractState,
            name: felt252,
            description: felt252,
            quorum: felt252,
            salt: felt252,
        ) -> ContractAddress {
            let dao_count = self.dao_count.read();
            let mut constructor_calldata = array![];
            let deployer = get_caller_address();

            assert(
                self.dao_creation_state.read() == DAOCreationState::CREATIONRESUMED,
                'Dao Creation Paused',
            );

            // TODO:
            // Arrange these params according to the core constructor
            deployer.serialize(ref constructor_calldata);
            name.serialize(ref constructor_calldata);
            description.serialize(ref constructor_calldata);
            quorum.serialize(ref constructor_calldata);

            let core_hash = self.core_hash.read();
            let result = deploy_syscall(core_hash, salt, constructor_calldata.span(), false);
            let (dao_address, _) = result.unwrap_syscall();

            let dao = DAO {
                index: dao_count,
                address: dao_address,
                deployer,
                deployed_at: get_block_timestamp(),
            };

            self.deployed_daos.entry(dao_address).write(dao);
            self.dao_count.write(dao_count + 1);

            self
                .emit(
                    DAODeployed {
                        index: dao_count, deployer, deployed_at: get_block_timestamp(), dao_address,
                    },
                );

            dao_address
        }

        // Get total number of DAOs in existence.
        fn get_dao_count(self: @ContractState) -> u32 {
            self.dao_count.read()
        }

        // Get the current creation state of the DAO builder.
        fn get_dao_creation_state(self: @ContractState) -> DAOCreationState {
            self.dao_creation_state.read()
        }

        fn get_core_hash(self: @ContractState) -> ClassHash {
            self.core_hash.read()
        }

        fn get_owner(self: @ContractState) -> ContractAddress {
            self.ownable.assert_only_owner();
            self.ownable.owner()
        }

        // Pick one implementation for fetching details of a given DAO.
        // fn get_dao_by_index(self: @ContractState, index: felt252) -> DAO {}
        fn get_dao_by_address(self: @ContractState, address: ContractAddress) -> DAO {
            self.deployed_daos.entry(address).read()
        }

        // Temporary pauses/unpauses creation of new DAOs. Only the Core Team or the deployer of
        // dao_builder can call these functions.
        fn pause_creation(ref self: ContractState) -> bool {
            self.ownable.assert_only_owner();
            let mut dao_creation_state = self.dao_creation_state.read();
            assert(
                dao_creation_state != DAOCreationState::CREATIONPAUSED, 'Creation already paused',
            );
            dao_creation_state = DAOCreationState::CREATIONPAUSED;

            self.dao_creation_state.write(dao_creation_state);

            self
                .emit(
                    CreationStateChanged {
                        new_state: DAOCreationState::CREATIONPAUSED,
                        state_changed_at: get_block_timestamp(),
                    },
                );

            true
        }
        fn resume_creation(ref self: ContractState) -> bool {
            self.ownable.assert_only_owner();
            let mut dao_creation_state = self.dao_creation_state.read();
            assert(
                dao_creation_state != DAOCreationState::CREATIONRESUMED, 'Creation already resumed',
            );
            dao_creation_state = DAOCreationState::CREATIONRESUMED;

            self.dao_creation_state.write(dao_creation_state);

            self
                .emit(
                    CreationStateChanged {
                        new_state: DAOCreationState::CREATIONRESUMED,
                        state_changed_at: get_block_timestamp(),
                    },
                );

            true
        }

        // This function can be called to update the DAO configuration of an existing DAO. Only
        // admin of the DAO can call this function.
        fn update_core_class_hash(
            ref self: ContractState, class_hash: ClassHash, dao_address: ContractAddress,
        ) { // TODO:
        // Use openzeppelin upgradeable component inside the core, and use dispatcher mechanism
        // to call it from here
        }
    }
}

