use contract::dao_core::{IDaoCoreDispatcher, IDaoCoreDispatcherTrait, MemberTier};
use core::serde::Serde;
use snforge_std::{ContractClassTrait, DeclareResultTrait, declare};
use starknet::ContractAddress;

// Test addresses
fn owner() -> ContractAddress {
    'owner'.try_into().unwrap()
}

fn admin() -> ContractAddress {
    'admin'.try_into().unwrap()
}

fn member() -> ContractAddress {
    'member'.try_into().unwrap()
}

fn deploy_dao_core(
    owner: ContractAddress, name: felt252, description: felt252, quorum: felt252,
) -> IDaoCoreDispatcher {
    let dao_core_class = declare("DaoCore").unwrap().contract_class();
    let mut constructor_calldata = array![];
    owner.serialize(ref constructor_calldata);
    name.serialize(ref constructor_calldata);
    description.serialize(ref constructor_calldata);
    quorum.serialize(ref constructor_calldata);

    let (contract_address, _) = dao_core_class.deploy(@constructor_calldata).unwrap();
    IDaoCoreDispatcher { contract_address }
}

#[test]
fn test_constructor_sets_owner_correctly() {
    let dao_core = deploy_dao_core(owner(), 'TestDAO', 'Test Description', 100);

    // Verify that the owner is set correctly
    let stored_owner = dao_core.get_owner();
    assert(stored_owner == owner(), 'Owner should be set correctly');
}

#[test]
fn test_constructor_sets_name_correctly() {
    let dao_core = deploy_dao_core(owner(), 'TestDAO', 'Test Description', 100);

    // Verify that the name is set correctly
    let stored_name = dao_core.get_dao_name();
    assert(stored_name == 'TestDAO', 'Name should be set correctly');
}

#[test]
fn test_constructor_initializes_member_counts_to_zero() {
    let dao_core = deploy_dao_core(owner(), 'TestDAO', 'Test Description', 100);

    // Verify that admin_count is initialized to 0
    let admin_count = dao_core.get_member_count(MemberTier::SubCommittee);
    assert(admin_count == 0, 'Admin count should be 0');

    // Verify that member_count is initialized to 0
    let member_count = dao_core.get_member_count(MemberTier::GeneralMember);
    assert(member_count == 0, 'Member count should be 0');
}

#[test]
#[should_panic]
fn test_constructor_fails_with_zero_owner_address() {
    let dao_core_class = declare("DaoCore").unwrap().contract_class();
    let mut constructor_calldata = array![];
    let zero_address: ContractAddress = 0.try_into().unwrap();
    zero_address.serialize(ref constructor_calldata);
    'TestDAO'.serialize(ref constructor_calldata);
    'Test Description'.serialize(ref constructor_calldata);
    100.serialize(ref constructor_calldata);

    // This should panic with "Owner address cannot be zero"
    let (_, _) = dao_core_class.deploy(@constructor_calldata).unwrap();
}

#[test]
fn test_constructor_with_different_owner_address() {
    let dao_core = deploy_dao_core(admin(), 'DifferentDAO', 'Different Description', 50);

    // Verify that the owner is set to the admin address
    let stored_owner = dao_core.get_owner();
    assert(stored_owner == admin(), 'Owner should be admin');

    // Verify that the name is set correctly
    let stored_name = dao_core.get_dao_name();
    assert(stored_name == 'DifferentDAO', 'Name should be DifferentDAO');
}

#[test]
fn test_constructor_with_empty_name() {
    let dao_core = deploy_dao_core(owner(), 0, 'Empty Name Description', 75);

    // Verify that the name is set to empty
    let stored_name = dao_core.get_dao_name();
    assert(stored_name == 0, 'Name should be empty');
}

#[test]
fn test_constructor_with_large_name() {
    let dao_core = deploy_dao_core(owner(), 'VeryLongDaoName', 'Long Name Description', 200);

    // Verify that the long name is set correctly
    let stored_name = dao_core.get_dao_name();
    assert(stored_name == 'VeryLongDaoName', 'Long name should be set');
}

#[test]
fn test_constructor_owner_has_correct_role() {
    let dao_core = deploy_dao_core(owner(), 'TestDAO', 'Test Description', 100);

    // Verify that the owner has the correct role (Owner = 1)
    let owner_role = dao_core.get_role(owner());
    assert(owner_role == 1, 'Owner should have role 1');

    // Verify that the owner is recognized as a member
    let is_owner_member = dao_core.is_member(owner(), MemberTier::Owner);
    assert(is_owner_member == true, 'Owner should be owner member');
}

#[test]
fn test_constructor_non_owner_has_no_role() {
    let dao_core = deploy_dao_core(owner(), 'TestDAO', 'Test Description', 100);

    // Verify that a non-owner address has no role (0)
    let non_owner_role = dao_core.get_role(member());
    assert(non_owner_role == 0, 'Non-owner should have role 0');

    // Verify that a non-owner is not recognized as any member
    let is_owner_member = dao_core.is_member(member(), MemberTier::Owner);
    assert(is_owner_member == false, 'Non-owner not owner member');

    let is_admin_member = dao_core.is_member(member(), MemberTier::SubCommittee);
    assert(is_admin_member == false, 'Non-owner not admin member');

    let is_general_member = dao_core.is_member(member(), MemberTier::GeneralMember);
    assert(is_general_member == false, 'Non-owner not general member');
}

#[test]
fn test_constructor_with_different_quorum_values() {
    // Test with zero quorum
    let dao_core_zero = deploy_dao_core(owner(), 'TestDAO', 'Test Description', 0);

    // Test with maximum quorum (using a large number)
    let dao_core_max = deploy_dao_core(admin(), 'TestDAO', 'Test Description', 999999);

    // Test with decimal-like quorum (should work as felt252)
    let dao_core_decimal = deploy_dao_core(member(), 'TestDAO', 'Test Description', 12345);

    // All should deploy successfully with different quorum values
    assert(dao_core_zero.get_owner() == owner(), 'Zero quorum should work');
    assert(dao_core_max.get_owner() == admin(), 'Max quorum should work');
    assert(dao_core_decimal.get_owner() == member(), 'Decimal quorum should work');
}

#[test]
fn test_constructor_next_proposal_id_initialization() {
    let dao_core = deploy_dao_core(owner(), 'TestDAO', 'Test Description', 100);

    // Create a proposal to test that next_proposal_id starts at 1
    let current_time = 1000;
    let end_time = current_time + 3600; // 1 hour later

    // The first proposal should have ID 1 (since next_proposal_id starts at 1)
    let proposal_id = dao_core.create_proposal(owner(), current_time, end_time);
    assert(proposal_id == 1, 'First proposal should have ID 1');

    // Create another proposal to verify incrementing
    let proposal_id2 = dao_core.create_proposal(owner(), current_time + 100, end_time + 100);
    assert(proposal_id2 == 2, 'Second proposal ID 2');
}

#[test]
fn test_constructor_with_maximum_values() {
    // Test with large felt252 values for name and description
    let max_name: felt252 = 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    let max_description: felt252 = 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    let max_quorum: felt252 = 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    let dao_core = deploy_dao_core(owner(), max_name, max_description, max_quorum);

    // Verify that maximum values are stored correctly
    let stored_name = dao_core.get_dao_name();
    assert(stored_name == max_name, 'Max name should be stored');

    // Verify the contract is still functional
    let stored_owner = dao_core.get_owner();
    assert(stored_owner == owner(), 'Owner set with max values');

    // Verify member counts still work
    let admin_count = dao_core.get_member_count(MemberTier::SubCommittee);
    assert(admin_count == 0, 'Admin count 0 with max values');
}
