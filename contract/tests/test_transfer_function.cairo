use starknet::ContractAddress;
use snforge_std::{
    declare, ContractClassTrait, DeclareResultTrait, start_cheat_caller_address,
    stop_cheat_caller_address, spy_events, EventSpyAssertionsTrait, EventSpyTrait
};
use core::serde::Serde;

use contract::dao_core::{
    IDaoCoreDispatcher, IDaoCoreDispatcherTrait, MemberTier, 
    DaoCore::Event, DaoCore::OwnershipTransferred
};

fn deploy_dao_core(owner: ContractAddress, name: felt252, description: felt252, quorum: felt252) -> IDaoCoreDispatcher {
    let dao_core_class = declare("DaoCore").unwrap().contract_class();
    let mut constructor_calldata = array![];
    owner.serialize(ref constructor_calldata);
    name.serialize(ref constructor_calldata);
    description.serialize(ref constructor_calldata);
    quorum.serialize(ref constructor_calldata);
    
    let (contract_address, _) = dao_core_class.deploy(@constructor_calldata).unwrap();
    IDaoCoreDispatcher { contract_address }
}

// ========== Transfer Ownership Success Tests ==========

#[test]
fn test_transfer_ownership_success() {
    
    let owner: ContractAddress = 'owner'.try_into().unwrap();
    let new_owner: ContractAddress = 'new_owner'.try_into().unwrap();
    let dao_name: felt252 = 'TestDAO';
    let description: felt252 = 'Test DAO Description';
    let quorum: felt252 = 'TestQuorum';
    
    let dao_core = deploy_dao_core(owner, dao_name, description, quorum);
    
    
    let mut spy = spy_events();
    
    
    start_cheat_caller_address(dao_core.contract_address, owner);
    
    dao_core.transfer_ownership(new_owner);
    
    stop_cheat_caller_address(dao_core.contract_address);
    
    
    let current_owner = dao_core.get_owner();
    assert!(current_owner == new_owner, "Ownership should be transferred to new owner");
    
    
    spy.assert_emitted(@array![
        (dao_core.contract_address, Event::OwnershipTransferred(
            OwnershipTransferred { 
                previous_owner: owner, 
                new_owner: new_owner 
            }
        ))
    ]);
}

// ========== Non-Owner Access Control Tests ==========

#[test]
#[should_panic]
fn test_transfer_ownership_non_owner_fails() {
    let owner: ContractAddress = 'owner'.try_into().unwrap();
    let non_owner: ContractAddress = 'non_owner'.try_into().unwrap();
    let new_owner: ContractAddress = 'new_owner'.try_into().unwrap();
    let dao_name: felt252 = 'TestDAO';
    let description: felt252 = 'Test DAO Description';
    let quorum: felt252 = 'TestQuorum';
    
    let dao_core = deploy_dao_core(owner, dao_name, description, quorum);

    start_cheat_caller_address(dao_core.contract_address, non_owner);
    
    dao_core.transfer_ownership(new_owner);
    
    stop_cheat_caller_address(dao_core.contract_address);
}

// ========== Zero Address Validation Tests ==========

#[test]
#[should_panic]
fn test_transfer_ownership_zero_address_fails() {
    let owner: ContractAddress = 'owner'.try_into().unwrap();
    let zero_address: ContractAddress = 0.try_into().unwrap();
    let dao_name: felt252 = 'TestDAO';
    let description: felt252 = 'Test DAO Description';
    let quorum: felt252 = 'TestQuorum';
    
    let dao_core = deploy_dao_core(owner, dao_name, description, quorum);
    start_cheat_caller_address(dao_core.contract_address, owner);
    
    dao_core.transfer_ownership(zero_address);
    
    stop_cheat_caller_address(dao_core.contract_address);
}

// ========== Comprehensive Ownership Transfer Tests ==========

#[test]
fn test_transfer_ownership_comprehensive() {
    let owner: ContractAddress = 'owner'.try_into().unwrap();
    let new_owner: ContractAddress = 'new_owner'.try_into().unwrap();
    let third_owner: ContractAddress = 'third_owner'.try_into().unwrap();
    let dao_name: felt252 = 'TestDAO';
    let description: felt252 = 'Test DAO Description';
    let quorum: felt252 = 'TestQuorum';
    
    let dao_core = deploy_dao_core(owner, dao_name, description, quorum);
    
    let mut spy = spy_events();

    let initial_owner = dao_core.get_owner();
    assert!(initial_owner == owner, "Initial owner should be set correctly");

    start_cheat_caller_address(dao_core.contract_address, owner);
    dao_core.transfer_ownership(new_owner);
    stop_cheat_caller_address(dao_core.contract_address);

    let current_owner = dao_core.get_owner();
    assert!(current_owner == new_owner, "First ownership transfer should succeed");
    
    spy.assert_emitted(@array![
        (dao_core.contract_address, Event::OwnershipTransferred(
            OwnershipTransferred { 
                previous_owner: owner, 
                new_owner: new_owner 
            }
        ))
    ]);
    
    start_cheat_caller_address(dao_core.contract_address, new_owner);
    dao_core.transfer_ownership(third_owner);
    stop_cheat_caller_address(dao_core.contract_address);
    
    let final_owner = dao_core.get_owner();
    assert!(final_owner == third_owner, "Second ownership transfer should succeed");
    
    spy.assert_emitted(@array![
        (dao_core.contract_address, Event::OwnershipTransferred(
            OwnershipTransferred { 
                previous_owner: new_owner, 
                new_owner: third_owner 
            }
        ))
    ]);
}

// ========== Access Control After Transfer Tests ==========

#[test]
#[should_panic]
fn test_previous_owner_cannot_transfer_after_ownership_change() {
    let owner: ContractAddress = 'owner'.try_into().unwrap();
    let new_owner: ContractAddress = 'new_owner'.try_into().unwrap();
    let third_party: ContractAddress = 'third_party'.try_into().unwrap();
    let dao_name: felt252 = 'TestDAO';
    let description: felt252 = 'Test DAO Description';
    let quorum: felt252 = 'TestQuorum';
    
    let dao_core = deploy_dao_core(owner, dao_name, description, quorum);
 
    start_cheat_caller_address(dao_core.contract_address, owner);
    dao_core.transfer_ownership(new_owner);
    stop_cheat_caller_address(dao_core.contract_address);
    
    start_cheat_caller_address(dao_core.contract_address, owner);
    
    dao_core.transfer_ownership(third_party);
    
    stop_cheat_caller_address(dao_core.contract_address);
}

// ========== Edge Cases Tests ==========

#[test]
fn test_transfer_ownership_to_self() {
    // Setup
    let owner: ContractAddress = 'owner'.try_into().unwrap();
    let dao_name: felt252 = 'TestDAO';
    let description: felt252 = 'Test DAO Description';
    let quorum: felt252 = 'TestQuorum';
    
    let dao_core = deploy_dao_core(owner, dao_name, description, quorum);
    
    let mut spy = spy_events();
    
    start_cheat_caller_address(dao_core.contract_address, owner);
    dao_core.transfer_ownership(owner);
    stop_cheat_caller_address(dao_core.contract_address);
    
    let current_owner = dao_core.get_owner();
    assert!(current_owner == owner, "Owner should remain the same when transferring to self");
    
    spy.assert_emitted(@array![
        (dao_core.contract_address, Event::OwnershipTransferred(
            OwnershipTransferred { 
                previous_owner: owner, 
                new_owner: owner 
            }
        ))
    ]);
}