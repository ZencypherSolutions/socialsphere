use starknet::ContractAddress;
use snforge_std::{
    declare, ContractClassTrait, DeclareResultTrait, start_cheat_caller_address,
    stop_cheat_caller_address, start_cheat_block_timestamp, stop_cheat_block_timestamp,
    spy_events, EventSpyAssertionsTrait
};
use core::array::ArrayTrait;
use core::num::traits::Zero;
use core::serde::Serde;

use contract::dao_builder::{
    IDaoBuilderDispatcher, IDaoBuilderDispatcherTrait, DAOCreationState, DaoBuilder
};
use DaoBuilder::{DAODeployed, CreationStateChanged};
use contract::dao_core::{IDaoCoreDispatcher, IDaoCoreDispatcherTrait};

fn deploy_contract(name: ByteArray) -> ContractAddress {
    let contract = declare(name).unwrap().contract_class();
    let (contract_address, _) = contract.deploy(@ArrayTrait::new()).unwrap();
    contract_address
}



#[test]
#[should_panic(expected: ('Dao Creation Paused',))]
fn test_dao_factory_core_functionality() {
    // Setup
    let owner: ContractAddress = 'owner'.try_into().unwrap();

    let deployer: ContractAddress = 'deployer'.try_into().unwrap();

    let initial_timestamp: u64 = 1000;
    
    // Declare DaoCore and DaoBuilder
    let dao_core_class = declare("DaoCore").unwrap().contract_class();
    let dao_core_class_hash = dao_core_class.class_hash;
    let dao_builder_class = declare("DaoBuilder").unwrap().contract_class();
    let mut constructor_calldata = array![];
    dao_core_class_hash.serialize(ref constructor_calldata);
    owner.serialize(ref constructor_calldata);
    let (dao_builder_address, _) = dao_builder_class.deploy(@constructor_calldata).unwrap();
    let dao_builder = IDaoBuilderDispatcher { contract_address: dao_builder_address };

    // Set timestamp
    start_cheat_block_timestamp(dao_builder_address, initial_timestamp);
    start_cheat_caller_address(dao_builder_address, deployer);
    
    // Event spy
    let mut spy = spy_events();

    // Test data
    let dao_name: felt252 = 'TestDAO';
    let dao_description: felt252 = 'Test DAO Description';
    let dao_quorum: felt252 = 50;
    let salt: felt252 = 'unique_salt_123';

    // Test 1: Create DAO: this will pass
    let initial_dao_count = dao_builder.get_dao_count();
    assert(initial_dao_count == 0, 'Initial DAO count should be 0');

    let dao_address = dao_builder.create_dao(dao_name, dao_description, dao_quorum, salt);
    assert(dao_address.is_non_zero(), 'DAO address should not be zero');

    // Test 2: Verify DAODeployed event: this will pass
    let expected_events = array![
        (
            dao_builder_address,
            DaoBuilder::Event::DAODeployed(
                DAODeployed {
                    index: 0,
                    deployer: deployer,
                    deployed_at: initial_timestamp,
                    dao_address: dao_address,
                }
            )
        )
    ];
    spy.assert_emitted(@expected_events);

    // Test 3: Verify dao_count: this will pass
    let new_dao_count = dao_builder.get_dao_count();
    assert(new_dao_count == initial_dao_count + 1, 'DAO count should increment');

    // Test 4: Verify DAO metadata: this will pass
    let retrieved_dao = dao_builder.get_dao_by_address(dao_address);
    assert(retrieved_dao.index == 0, 'DAO index should be 0');
    assert(retrieved_dao.address == dao_address, 'DAO address should match');
    assert(retrieved_dao.deployer == deployer, 'DAO deployer should match');
    assert(retrieved_dao.deployed_at == initial_timestamp, 'DAO deployed_at should match');

    // Test 5: Verify DaoCore: this will pass
    let dao_core = IDaoCoreDispatcher { contract_address: dao_address };

    let retrieved_name = dao_core.get_dao_name();
    assert(retrieved_name == dao_name, 'DAO name should match');

    let dao_owner = dao_core.get_owner();
    assert(dao_owner == deployer, 'DAO owner should be deployer');

    // Test 6: Pause creation: this will pass
    stop_cheat_caller_address(dao_builder_address);
    start_cheat_caller_address(dao_builder_address, owner);
    let pause_result = dao_builder.pause_creation();
    assert!(pause_result, "Pause creation should return true");

    let pause_events = array![
        (
            dao_builder_address,
            DaoBuilder::Event::CreationStateChanged(
                CreationStateChanged {
                    new_state: DAOCreationState::CREATIONPAUSED,
                    state_changed_at: initial_timestamp,
                }
            )
        )
    ];
    spy.assert_emitted(@pause_events);
    stop_cheat_caller_address(dao_builder_address);

    // Test 7: Create DAO while paused: this should cause the test to panic
    
    start_cheat_caller_address(dao_builder_address, deployer);

    dao_builder.create_dao('AnotherDAO', 'Another Description', 60, 'different_salt');

    stop_cheat_caller_address(dao_builder_address);
    stop_cheat_block_timestamp(dao_builder_address);
}
