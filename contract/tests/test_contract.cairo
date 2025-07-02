
use snforge_std::{
    declare, ContractClassTrait, DeclareResultTrait, start_cheat_caller_address,
    stop_cheat_caller_address, start_cheat_block_timestamp,
};

use contract::dao_builder::{IDaoBuilderDispatcher, IDaoBuilderDispatcherTrait};
use contract::dao_core::{IDaoCoreDispatcher, IDaoCoreDispatcherTrait};
use starknet::ContractAddress;

fn setup_dao_builder() -> (IDaoBuilderDispatcher, ContractAddress, ContractAddress, u64) {
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
    
    (dao_builder, owner, deployer, initial_timestamp)
}

#[test]
fn test_dao_count_increments_after_creation() {
    // Setup
    let (dao_builder, _, deployer, _) = setup_dao_builder();
    start_cheat_caller_address(dao_builder.contract_address, deployer);
    
    // Test data
    let dao_name: felt252 = 'TestDAO';
    let dao_description: felt252 = 'Test DAO Description';
    let dao_quorum: felt252 = 50;
    let salt: felt252 = 'unique_salt_123';

    // Test
    let initial_dao_count = dao_builder.get_dao_count();
    dao_builder.create_dao(dao_name, dao_description, dao_quorum, salt);
    let new_dao_count = dao_builder.get_dao_count();
    
    assert(new_dao_count == initial_dao_count + 1, 'DAO count should increment');
    stop_cheat_caller_address(dao_builder.contract_address);
}

#[test]
fn test_dao_metadata_retrieval() {
    // Setup
    let (dao_builder, _, deployer, initial_timestamp) = setup_dao_builder();
    start_cheat_caller_address(dao_builder.contract_address, deployer);
    
    // Test data
    let dao_name: felt252 = 'TestDAO';
    let dao_description: felt252 = 'Test DAO Description';
    let dao_quorum: felt252 = 50;
    let salt: felt252 = 'unique_salt_123';

    // Test
    let dao_address = dao_builder.create_dao(dao_name, dao_description, dao_quorum, salt);
    let retrieved_dao = dao_builder.get_dao_by_address(dao_address);
    
    assert(retrieved_dao.index == 0, 'DAO index should be 0');
    assert(retrieved_dao.address == dao_address, 'DAO address should match');
    assert(retrieved_dao.deployer == deployer, 'DAO deployer should match');
    assert(retrieved_dao.deployed_at == initial_timestamp, 'DAO deployed_at should match');
    stop_cheat_caller_address(dao_builder.contract_address);
}

#[test]
fn test_dao_core_initialization() {
    // Setup
    let (dao_builder, _, deployer, _) = setup_dao_builder();
    start_cheat_caller_address(dao_builder.contract_address, deployer);
    
    // Test data
    let dao_name: felt252 = 'TestDAO';
    let dao_description: felt252 = 'Test DAO Description';
    let dao_quorum: felt252 = 50;
    let salt: felt252 = 'unique_salt_123';

    // Test
    let dao_address = dao_builder.create_dao(dao_name, dao_description, dao_quorum, salt);
    let dao_core = IDaoCoreDispatcher { contract_address: dao_address };

    let retrieved_name = dao_core.get_dao_name();
    assert(retrieved_name == dao_name, 'DAO name should match');

    let dao_owner = dao_core.get_owner();
    assert(dao_owner == deployer, 'DAO owner should be deployer');
    stop_cheat_caller_address(dao_builder.contract_address);
}


#[test]
#[should_panic(expected: ('Dao Creation Paused',))]
fn test_create_dao_while_paused_fails() {
    // Setup
    let (dao_builder, owner, deployer, _) = setup_dao_builder();
    
    // First pause creation
    start_cheat_caller_address(dao_builder.contract_address, owner);
    dao_builder.pause_creation();
    stop_cheat_caller_address(dao_builder.contract_address);
    
    // Then try to create DAO as deployer (should panic)
    start_cheat_caller_address(dao_builder.contract_address, deployer);
    dao_builder.create_dao('AnotherDAO', 'Another Description', 60, 'different_salt');

    
}