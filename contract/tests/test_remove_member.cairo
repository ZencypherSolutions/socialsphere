use starknet::ContractAddress;
use snforge_std::{
    declare, ContractClassTrait, DeclareResultTrait, start_cheat_caller_address,
    stop_cheat_caller_address, spy_events, EventSpyAssertionsTrait
};
use core::serde::Serde;

use contract::dao_core::{
    IDaoCoreDispatcher, IDaoCoreDispatcherTrait, DaoCore, MemberTier
};
use DaoCore::MemberRemoved;

// Setup helper function to deploy and initialize a DAO
fn setup_dao() -> (IDaoCoreDispatcher, ContractAddress, ContractAddress, ContractAddress, ContractAddress) {
    let owner: ContractAddress = 'owner'.try_into().unwrap();
    let admin1: ContractAddress = 'admin1'.try_into().unwrap();
    let admin2: ContractAddress = 'admin2'.try_into().unwrap();
    let member1: ContractAddress = 'member1'.try_into().unwrap();
    
    // Deploy DaoCore contract
    let dao_core_class = declare("DaoCore").unwrap().contract_class();
    let mut constructor_calldata = array![];
    owner.serialize(ref constructor_calldata);
    'TestDAO'.serialize(ref constructor_calldata);
    'Test Description'.serialize(ref constructor_calldata);
    50.serialize(ref constructor_calldata); // quorum
    
    let (dao_address, _) = dao_core_class.deploy(@constructor_calldata).unwrap();
    let dao = IDaoCoreDispatcher { contract_address: dao_address };
    
    // Setup initial members
    start_cheat_caller_address(dao.contract_address, owner);
    dao.add_member(admin1, MemberTier::SubCommittee);
    dao.add_member(admin2, MemberTier::SubCommittee);
    dao.add_member(member1, MemberTier::GeneralMember);
    stop_cheat_caller_address(dao.contract_address);
    
    (dao, owner, admin1, admin2, member1)
}

#[test]
fn test_owner_removes_admin_successfully() {
    let (dao, owner, admin1, _, _) = setup_dao();
    let mut spy = spy_events();
    
    // Verify admin exists before removal
    assert(dao.is_member(admin1, MemberTier::SubCommittee), 'Admin exists');
    let initial_admin_count = dao.get_member_count(MemberTier::SubCommittee);
    
    // Owner removes admin
    start_cheat_caller_address(dao.contract_address, owner);
    dao.remove_member(admin1);
    stop_cheat_caller_address(dao.contract_address);
    
    // Verify admin was removed
    assert(!dao.is_member(admin1, MemberTier::SubCommittee), 'Admin removed');
    
    // Verify admin_count decremented
    let new_admin_count = dao.get_member_count(MemberTier::SubCommittee);
    assert(new_admin_count == initial_admin_count - 1, 'Count decremented');
    
    // Verify MemberRemoved event was emitted
    let expected_events = array![
        (
            dao.contract_address,
            DaoCore::Event::MemberRemoved(MemberRemoved { member_address: admin1 })
        )
    ];
    spy.assert_emitted(@expected_events);
}

#[test]
fn test_owner_removes_general_member_successfully() {
    let (dao, owner, _, _, member1) = setup_dao();
    let mut spy = spy_events();
    
    // Verify member exists before removal
    assert(dao.is_member(member1, MemberTier::GeneralMember), 'Member exists');
    let initial_member_count = dao.get_member_count(MemberTier::GeneralMember);
    
    // Owner removes general member
    start_cheat_caller_address(dao.contract_address, owner);
    dao.remove_member(member1);
    stop_cheat_caller_address(dao.contract_address);
    
    // Verify member was removed
    assert(!dao.is_member(member1, MemberTier::GeneralMember), 'Member removed');
    
    // Verify member_count decremented
    let new_member_count = dao.get_member_count(MemberTier::GeneralMember);
    assert(new_member_count == initial_member_count - 1, 'Count decremented');
    
    // Verify MemberRemoved event was emitted
    let expected_events = array![
        (
            dao.contract_address,
            DaoCore::Event::MemberRemoved(MemberRemoved { member_address: member1 })
        )
    ];
    spy.assert_emitted(@expected_events);
}

#[test]
fn test_admin_removes_general_member_successfully() {
    let (dao, _, admin1, _, member1) = setup_dao();
    let mut spy = spy_events();
    
    // Verify member exists before removal
    assert(dao.is_member(member1, MemberTier::GeneralMember), 'Member exists');
    let initial_member_count = dao.get_member_count(MemberTier::GeneralMember);
    
    // Admin removes general member
    start_cheat_caller_address(dao.contract_address, admin1);
    dao.remove_member(member1);
    stop_cheat_caller_address(dao.contract_address);
    
    // Verify member was removed
    assert(!dao.is_member(member1, MemberTier::GeneralMember), 'Member removed');
    
    // Verify member_count decremented
    let new_member_count = dao.get_member_count(MemberTier::GeneralMember);
    assert(new_member_count == initial_member_count - 1, 'Count decremented');
    
    // Verify MemberRemoved event was emitted
    let expected_events = array![
        (
            dao.contract_address,
            DaoCore::Event::MemberRemoved(MemberRemoved { member_address: member1 })
        )
    ];
    spy.assert_emitted(@expected_events);
}

#[test]
#[should_panic]
fn test_admin_cannot_remove_another_admin() {
    let (dao, _, admin1, admin2, _) = setup_dao();
    
    // Admin tries to remove another admin (should fail)
    start_cheat_caller_address(dao.contract_address, admin1);
    dao.remove_member(admin2);
    stop_cheat_caller_address(dao.contract_address);
}

#[test]
#[should_panic]
fn test_member_cannot_remove_admin() {
    let (dao, _, admin1, _, member1) = setup_dao();
    
    // General member tries to remove admin (should fail)
    start_cheat_caller_address(dao.contract_address, member1);
    dao.remove_member(admin1);
    stop_cheat_caller_address(dao.contract_address);
}

#[test]
#[should_panic]
fn test_non_member_cannot_remove_general_member() {
    let (dao, _, _, _, member1) = setup_dao();
    let non_member: ContractAddress = 'non_member'.try_into().unwrap();
    
    // Non-member tries to remove general member (should fail)
    start_cheat_caller_address(dao.contract_address, non_member);
    dao.remove_member(member1);
    stop_cheat_caller_address(dao.contract_address);
}

#[test]
#[should_panic]
fn test_cannot_remove_dao_owner() {
    let (dao, owner, _, _, _) = setup_dao();
    
    // Try to remove the DAO owner (should fail)
    start_cheat_caller_address(dao.contract_address, owner);
    dao.remove_member(owner);
    stop_cheat_caller_address(dao.contract_address);
}

#[test]
#[should_panic]
fn test_remove_non_existent_member() {
    let (dao, owner, _, _, _) = setup_dao();
    let non_existent: ContractAddress = 'non_existent'.try_into().unwrap();
    
    // Try to remove a member that doesn't exist in any tier
    start_cheat_caller_address(dao.contract_address, owner);
    dao.remove_member(non_existent);
    stop_cheat_caller_address(dao.contract_address);
}

#[test]
#[should_panic]
fn test_remove_zero_address() {
    let (dao, owner, _, _, _) = setup_dao();
    let zero_address: ContractAddress = 0.try_into().unwrap();
    
    // Try to remove zero address (should fail)
    start_cheat_caller_address(dao.contract_address, owner);
    dao.remove_member(zero_address);
    stop_cheat_caller_address(dao.contract_address);
}

#[test]
fn test_role_returns_zero_after_removal() {
    let (dao, owner, admin1, _, member1) = setup_dao();
    
    // Verify roles before removal
    assert(dao.get_role(admin1) == 2_u8, 'Admin role is 2');
    assert(dao.get_role(member1) == 3_u8, 'Member role is 3');
    
    // Remove admin and member
    start_cheat_caller_address(dao.contract_address, owner);
    dao.remove_member(admin1);
    dao.remove_member(member1);
    stop_cheat_caller_address(dao.contract_address);
    
    // Verify roles after removal
    assert(dao.get_role(admin1) == 0_u8, 'Admin role is 0');
    assert(dao.get_role(member1) == 0_u8, 'Member role is 0');
}

#[test]
fn test_multiple_removals_update_counts_correctly() {
    let (dao, owner, admin1, admin2, member1) = setup_dao();
    
    // Add another general member
    let member2: ContractAddress = 'member2'.try_into().unwrap();
    start_cheat_caller_address(dao.contract_address, owner);
    dao.add_member(member2, MemberTier::GeneralMember);
    
    // Check initial counts
    let initial_admin_count = dao.get_member_count(MemberTier::SubCommittee);
    let initial_member_count = dao.get_member_count(MemberTier::GeneralMember);
    
    // Remove multiple members
    dao.remove_member(admin1);
    dao.remove_member(admin2);
    dao.remove_member(member1);
    dao.remove_member(member2);
    stop_cheat_caller_address(dao.contract_address);
    
    // Verify counts
    let final_admin_count = dao.get_member_count(MemberTier::SubCommittee);
    let final_member_count = dao.get_member_count(MemberTier::GeneralMember);
    
    assert(final_admin_count == initial_admin_count - 2, 'Admin count -2');
    assert(final_member_count == initial_member_count - 2, 'Member count -2');
}

#[test]
fn test_owner_count_unchanged_after_member_removals() {
    let (dao, owner, admin1, _, member1) = setup_dao();
    
    // Check initial owner count
    let initial_owner_count = dao.get_member_count(MemberTier::Owner);
    assert(initial_owner_count == 1, 'Should have 1 owner');
    
    // Remove admin and member
    start_cheat_caller_address(dao.contract_address, owner);
    dao.remove_member(admin1);
    dao.remove_member(member1);
    stop_cheat_caller_address(dao.contract_address);
    
    // Verify owner count remains unchanged
    let final_owner_count = dao.get_member_count(MemberTier::Owner);
    assert(final_owner_count == 1, 'Owner count remains 1');
    
    // Verify owner is still the owner
    assert(dao.is_member(owner, MemberTier::Owner), 'Owner still owner');
} 