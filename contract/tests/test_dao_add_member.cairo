use contract::dao_builder::{IDaoBuilderDispatcher, IDaoBuilderDispatcherTrait};
use contract::dao_core::{IDaoCoreDispatcher, IDaoCoreDispatcherTrait, MemberTier};
use core::num::traits::Zero;
use core::serde::Serde;
use snforge_std::{
    ContractClassTrait, DeclareResultTrait, EventSpyAssertionsTrait,EventSpyTrait, declare, spy_events,
    start_cheat_block_timestamp, start_cheat_caller_address, stop_cheat_caller_address,
};
use starknet::{ContractAddress, contract_address_const};

fn owner() -> ContractAddress {
    1.try_into().unwrap()
}

fn member() -> ContractAddress {
    2.try_into().unwrap()
}

fn zero() -> ContractAddress {
    contract_address_const::<0>()
}

fn setup_dao_builder() -> (IDaoBuilderDispatcher, ContractAddress, ContractAddress, u64) {
    let owner: ContractAddress = owner();
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

// owner tier
#[test]
#[should_panic(expected: 'Cannot add owner via add_member')]
fn test_add_owner_with_add_member() {
    // Setup
    let (dao_builder, _, deployer, _) = setup_dao_builder();
    let member = member();
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

    dao_core.add_member(member, MemberTier::Owner);
    stop_cheat_caller_address(dao_builder.contract_address);
}

// subcommittee tier
#[test]
#[should_panic(expected: "Caller is not the DAO owner")]
fn test_non_owner_add_member() {
    // Setup
    let (dao_builder, _, deployer, _) = setup_dao_builder();
    let member = member();
    start_cheat_caller_address(dao_builder.contract_address, deployer);

    // Test data
    let dao_name: felt252 = 'TestDAO';
    let dao_description: felt252 = 'Test DAO Description';
    let dao_quorum: felt252 = 50;
    let salt: felt252 = 'unique_salt_123';

    // Test
    let dao_address = dao_builder.create_dao(dao_name, dao_description, dao_quorum, salt);
    let dao_core = IDaoCoreDispatcher { contract_address: dao_address };
    stop_cheat_caller_address(dao_builder.contract_address);

    let retrieved_name = dao_core.get_dao_name();
    assert(retrieved_name == dao_name, 'DAO name should match');

    start_cheat_caller_address(dao_builder.contract_address, member);

    dao_core.add_member(member, MemberTier::SubCommittee);
    stop_cheat_caller_address(dao_builder.contract_address);
}

#[test]
fn test_add_member_to_subcommitee_tier_success() {
    // Setup
    let (dao_builder, _, deployer, _) = setup_dao_builder();
    let member = member();
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
    stop_cheat_caller_address(dao_builder.contract_address);
    start_cheat_caller_address(dao_address, deployer);

    dao_core.add_member(member, MemberTier::SubCommittee);
    let member_count = dao_core.get_member_count(MemberTier::SubCommittee);
    let is_member = dao_core.is_member(member, MemberTier::SubCommittee);
    assert!(member_count == 1, "member count should be 1");
    assert!(is_member, "address should be a member");
    stop_cheat_caller_address(deployer);
}


#[test]
fn test_promote_member_to_subcommitee_tier_data_removal_on_general() {
    // Setup
    let (dao_builder, _, deployer, _) = setup_dao_builder();
    let member = member();
    start_cheat_caller_address(dao_builder.contract_address, deployer);

    // Test data
    let dao_name: felt252 = 'TestDAO';
    let dao_description: felt252 = 'Test DAO Description';
    let dao_quorum: felt252 = 50;
    let salt: felt252 = 'unique_salt_123';

    // Test
    let dao_address = dao_builder.create_dao(dao_name, dao_description, dao_quorum, salt);
    let dao_core = IDaoCoreDispatcher { contract_address: dao_address };
    stop_cheat_caller_address(dao_builder.contract_address);
    start_cheat_caller_address(dao_address, deployer);

    // add member to general tier
    dao_core.add_member(member, MemberTier::GeneralMember);
    let member_count = dao_core.get_member_count(MemberTier::GeneralMember);
    let is_member = dao_core.is_member(member, MemberTier::GeneralMember);
    assert!(member_count == 1, "member count should be 1");
    assert!(is_member, "address should be a member");

    // promote member to subcommitee
    dao_core.add_member(member, MemberTier::SubCommittee);
    let member_count = dao_core.get_member_count(MemberTier::SubCommittee);
    let is_member = dao_core.is_member(member, MemberTier::SubCommittee);
    assert!(member_count == 1, "member count should be 1");
    assert!(is_member, "address should be a member");

    // verify that member details has been remove from general tie
    let member_count = dao_core.get_member_count(MemberTier::GeneralMember);
    let is_member = dao_core.is_member(member, MemberTier::GeneralMember);
    assert!(member_count == 0, "member count should be 0");
    assert!(!is_member, "address should not be a member");
    stop_cheat_caller_address(deployer);
}

#[test]
fn test_promote_member_to_subcommitee_tier_success() {
    // Setup
    let (dao_builder, _, deployer, _) = setup_dao_builder();
    let member = member();
    start_cheat_caller_address(dao_builder.contract_address, deployer);

    // Test data
    let dao_name: felt252 = 'TestDAO';
    let dao_description: felt252 = 'Test DAO Description';
    let dao_quorum: felt252 = 50;
    let salt: felt252 = 'unique_salt_123';

    // Test
    let dao_address = dao_builder.create_dao(dao_name, dao_description, dao_quorum, salt);
    let dao_core = IDaoCoreDispatcher { contract_address: dao_address };
    stop_cheat_caller_address(dao_builder.contract_address);
    start_cheat_caller_address(dao_address, deployer);

    // add member to subcommitee
    dao_core.add_member(member, MemberTier::GeneralMember);

    // add member to general tier
    dao_core.add_member(member, MemberTier::SubCommittee);
    stop_cheat_caller_address(deployer);
}

#[test]
#[should_panic(expected: 'AlreadyAdmin')]
fn test_subcommitee_tier_to_promote_member_error() {
    // Setup
    let (dao_builder, _, deployer, _) = setup_dao_builder();
    let member = member();
    start_cheat_caller_address(dao_builder.contract_address, deployer);

    // Test data
    let dao_name: felt252 = 'TestDAO';
    let dao_description: felt252 = 'Test DAO Description';
    let dao_quorum: felt252 = 50;
    let salt: felt252 = 'unique_salt_123';

    // Test
    let dao_address = dao_builder.create_dao(dao_name, dao_description, dao_quorum, salt);
    let dao_core = IDaoCoreDispatcher { contract_address: dao_address };
    stop_cheat_caller_address(dao_builder.contract_address);
    start_cheat_caller_address(dao_address, deployer);

    // add member to subcommitee
    dao_core.add_member(member, MemberTier::SubCommittee);

    // add member to general tier
    dao_core.add_member(member, MemberTier::GeneralMember);
    stop_cheat_caller_address(deployer);
}


#[test]
fn test_add_subcommitee_tier_event_check_success() {
    // Setup
    let (dao_builder, _, deployer, _) = setup_dao_builder();
    let member = member();
    let mut spy = spy_events();
    start_cheat_caller_address(dao_builder.contract_address, deployer);

    // Test data
    let dao_name: felt252 = 'TestDAO';
    let dao_description: felt252 = 'Test DAO Description';
    let dao_quorum: felt252 = 50;
    let salt: felt252 = 'unique_salt_123';

    // Test
    let dao_address = dao_builder.create_dao(dao_name, dao_description, dao_quorum, salt);
    let dao_core = IDaoCoreDispatcher { contract_address: dao_address };
    stop_cheat_caller_address(dao_builder.contract_address);
    start_cheat_caller_address(dao_address, deployer);

    // add member to subcommitee
   dao_core.add_member(member, MemberTier::SubCommittee);
    // Fetch the MemberAdded event
    let events = spy.get_events();
    
    let tier_number = match events.events.into_iter().last() {
        Option::Some((
            _, event,
        )) => {
            let market_id_felt = *event.data.at(0); // Access first element
            market_id_felt // Convert felt252 to u256
        },
        Option::None => panic!("No MemberAdded event emitted"),
    };

    assert_eq!(tier_number, 2);
    stop_cheat_caller_address(deployer);
}


/// general member tier

#[test]
fn test_add_member_to_general_tier_success() {
    // Setup
    let (dao_builder, _, deployer, _) = setup_dao_builder();
    let member = member();
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
    stop_cheat_caller_address(dao_builder.contract_address);
    start_cheat_caller_address(dao_address, deployer);

    dao_core.add_member(member, MemberTier::GeneralMember);
    let member_count = dao_core.get_member_count(MemberTier::GeneralMember);
    let is_member = dao_core.is_member(member, MemberTier::GeneralMember);
    assert!(member_count == 1, "member count should be 1");
    assert!(is_member, "address should be a member");
    stop_cheat_caller_address(deployer);
}

#[test]
#[should_panic(expected: "Caller not authorized")]
fn test_non_owner_add_member_to_general_tier_error() {
    // Setup
    let (dao_builder, _, deployer, _) = setup_dao_builder();
    let member = member();
    start_cheat_caller_address(dao_builder.contract_address, deployer);

    // Test data
    let dao_name: felt252 = 'TestDAO';
    let dao_description: felt252 = 'Test DAO Description';
    let dao_quorum: felt252 = 50;
    let salt: felt252 = 'unique_salt_123';

    // Test
    let dao_address = dao_builder.create_dao(dao_name, dao_description, dao_quorum, salt);
    let dao_core = IDaoCoreDispatcher { contract_address: dao_address };

    dao_core.add_member(member, MemberTier::GeneralMember);
    stop_cheat_caller_address(dao_builder.contract_address);
}

#[test]
fn test_add_general_tier_event_check_success() {
    // Setup
    let (dao_builder, _, deployer, _) = setup_dao_builder();
    let member = member();
    let mut spy = spy_events();
    start_cheat_caller_address(dao_builder.contract_address, deployer);

    // Test data
    let dao_name: felt252 = 'TestDAO';
    let dao_description: felt252 = 'Test DAO Description';
    let dao_quorum: felt252 = 50;
    let salt: felt252 = 'unique_salt_123';

    // Test
    let dao_address = dao_builder.create_dao(dao_name, dao_description, dao_quorum, salt);
    let dao_core = IDaoCoreDispatcher { contract_address: dao_address };
    stop_cheat_caller_address(dao_builder.contract_address);
    start_cheat_caller_address(dao_address, deployer);

    // add member to subcommitee
    dao_core.add_member(member, MemberTier::GeneralMember);
    // Fetch the MemberAdded event
    let events = spy.get_events();
    let tier_number = match events.events.into_iter().last() {
        Option::Some((
            _, event,
        )) => {
            let market_id_felt = *event.data.at(0); // Access first element
            market_id_felt // Convert felt252 to u256
        },
        Option::None => panic!("No MemberAdded event emitted"),
    };

    assert_eq!(tier_number, 3);
    stop_cheat_caller_address(deployer);
}

// invalid  tier
#[test]
#[should_panic(expected: 'Invalid tier specified')]
fn test_invalid_tier_error() {
    // Setup
    let (dao_builder, _, deployer, _) = setup_dao_builder();
    let member = member();
    start_cheat_caller_address(dao_builder.contract_address, deployer);

    // Test data
    let dao_name: felt252 = 'TestDAO';
    let dao_description: felt252 = 'Test DAO Description';
    let dao_quorum: felt252 = 50;
    let salt: felt252 = 'unique_salt_123';

    // Test
    let dao_address = dao_builder.create_dao(dao_name, dao_description, dao_quorum, salt);
    let dao_core = IDaoCoreDispatcher { contract_address: dao_address };

    dao_core.add_member(member, MemberTier::None);
    stop_cheat_caller_address(dao_builder.contract_address);
}

#[test]
#[should_panic(expected: "Member address cannot be zero")]
fn test_zero_address_error() {
    // Setup
    let (dao_builder, _, deployer, _) = setup_dao_builder();
    let zero_address = zero();
    start_cheat_caller_address(dao_builder.contract_address, deployer);

    // Test data
    let dao_name: felt252 = 'TestDAO';
    let dao_description: felt252 = 'Test DAO Description';
    let dao_quorum: felt252 = 50;
    let salt: felt252 = 'unique_salt_123';

    // Test
    let dao_address = dao_builder.create_dao(dao_name, dao_description, dao_quorum, salt);
    let dao_core = IDaoCoreDispatcher { contract_address: dao_address };

    dao_core.add_member(zero_address, MemberTier::None);
    stop_cheat_caller_address(dao_builder.contract_address);
}
