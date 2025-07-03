use starknet::ContractAddress;
use snforge_std::{
    declare, ContractClassTrait, DeclareResultTrait, start_cheat_caller_address,
    stop_cheat_caller_address
};
use core::serde::Serde;


use contract::dao_core::{IDaoCoreDispatcher, IDaoCoreDispatcherTrait, MemberTier};

fn deploy_dao_core( owner: ContractAddress, name: felt252, description: felt252, quorum: felt252) -> IDaoCoreDispatcher {
    let dao_core_class = declare("DaoCore").unwrap().contract_class();
    let mut constructor_calldata = array![];
    owner.serialize(ref constructor_calldata);
    name.serialize(ref constructor_calldata);
    description.serialize(ref constructor_calldata);
    quorum.serialize(ref constructor_calldata);
    
    let (contract_address, _) = dao_core_class.deploy(@constructor_calldata).unwrap();
    IDaoCoreDispatcher { contract_address }
}

fn setup_dao_with_members() -> (IDaoCoreDispatcher, ContractAddress, ContractAddress, ContractAddress, ContractAddress) {
    let owner: ContractAddress = 'owner'.try_into().unwrap();
    let admin1: ContractAddress = 'admin1'.try_into().unwrap();
    let admin2: ContractAddress = 'admin2'.try_into().unwrap();
    let member1: ContractAddress = 'member1'.try_into().unwrap();
    let member2: ContractAddress = 'member2'.try_into().unwrap();
    let non_member: ContractAddress = 'non_member'.try_into().unwrap();
    
    let dao_name: felt252 = 'TestDAO';
    let dao_description: felt252 = 'Test Description';
    let dao_quorum: felt252 = 50;
    
    let dao_core = deploy_dao_core(owner, dao_name, dao_description, dao_quorum);
    
    // Add admins (only owner can add admins)
    start_cheat_caller_address(dao_core.contract_address, owner);
    dao_core.add_member(admin1, MemberTier::SubCommittee);
    dao_core.add_member(admin2, MemberTier::SubCommittee);
    
    // Add general members (owner or admin can add them)
    dao_core.add_member(member1, MemberTier::GeneralMember);
    dao_core.add_member(member2, MemberTier::GeneralMember);
    stop_cheat_caller_address(dao_core.contract_address);
    
    (dao_core, owner, admin1, member1, non_member)
}

// ========== is_member Tests ==========

#[test]
fn test_dao_core_is_member_owner_tier() {
    let (dao_core, owner, admin1, member1, non_member) = setup_dao_with_members();
    
    // Owner should be recognized as owner
    assert(dao_core.is_member(owner, MemberTier::Owner), 'Owner should be owner tier');
    
    // Non-owner addresses should not be owner tier
    assert(!dao_core.is_member(admin1, MemberTier::Owner), 'Admin should not be owner tier');
    assert(!dao_core.is_member(member1, MemberTier::Owner), 'Member should not be owner tier');
    assert(!dao_core.is_member(non_member, MemberTier::Owner), 'Non-member should not be owner');
}

#[test]
fn test_dao_core_is_member_subcommittee_tier() {
    let (dao_core, owner, admin1, member1, non_member) = setup_dao_with_members();
    
    // Admin should be recognized as subcommittee
    assert(dao_core.is_member(admin1, MemberTier::SubCommittee), 'Admin should be subcommittee');
    
    // Non-admin addresses should not be subcommittee tier
    assert(!dao_core.is_member(owner, MemberTier::SubCommittee), 'Owner should not be admin tier');
    assert(!dao_core.is_member(member1, MemberTier::SubCommittee), 'Member should not be admin');
    assert(!dao_core.is_member(non_member, MemberTier::SubCommittee), 'Non-member not admin');
}

#[test]
fn test_dao_core_is_member_general_member_tier() {
    let (dao_core, owner, admin1, member1, non_member) = setup_dao_with_members();
    
    // General member should be recognized as general member
    assert(dao_core.is_member(member1, MemberTier::GeneralMember), 'Member should be general');
    
    // Other addresses should not be general member tier
    assert(!dao_core.is_member(owner, MemberTier::GeneralMember), 'Owner not general member');
    assert(!dao_core.is_member(admin1, MemberTier::GeneralMember), 'Admin not general member');
    assert(!dao_core.is_member(non_member, MemberTier::GeneralMember), 'Non-member not general');
}

#[test]
fn test_dao_core_is_member_none_tier() {
    let (dao_core, owner, admin1, member1, non_member) = setup_dao_with_members();
    
    // None tier should always return false
    assert(!dao_core.is_member(owner, MemberTier::None), 'None tier should be false');
    assert(!dao_core.is_member(admin1, MemberTier::None), 'None tier should be false');
    assert(!dao_core.is_member(member1, MemberTier::None), 'None tier should be false');
    assert(!dao_core.is_member(non_member, MemberTier::None), 'None tier should be false');
}

// ========== get_role Tests ==========

#[test]
fn test_dao_core_get_role_owner() {
    let (dao_core, owner, _, _, _) = setup_dao_with_members();
    
    let role = dao_core.get_role(owner);
    assert(role == 1_u8, 'Owner role should be 1');
}

#[test]
fn test_dao_core_get_role_admin() {
    let (dao_core, _, admin1, _, _) = setup_dao_with_members();
    
    let role = dao_core.get_role(admin1);
    assert(role == 2_u8, 'Admin role should be 2');
}

#[test]
fn test_dao_core_get_role_general_member() {
    let (dao_core, _, _, member1, _) = setup_dao_with_members();
    
    let role = dao_core.get_role(member1);
    assert(role == 3_u8, 'General member role should be 3');
}

#[test]
fn test_dao_core_get_role_non_member() {
    let (dao_core, _, _, _, non_member) = setup_dao_with_members();
    
    let role = dao_core.get_role(non_member);
    assert(role == 0_u8, 'Non-member role should be 0');
}

// ========== get_owner Tests ==========

#[test]
fn test_dao_core_get_owner() {
    let owner: ContractAddress = 'test_owner'.try_into().unwrap();
    let dao_name: felt252 = 'TestDAO';
    let dao_description: felt252 = 'Test Description';
    let dao_quorum: felt252 = 50;
    
    let dao_core = deploy_dao_core(owner, dao_name, dao_description, dao_quorum);
    
    let retrieved_owner = dao_core.get_owner();
    assert(retrieved_owner == owner, 'Retrieved owner should match');
}

#[test]
fn test_dao_core_get_owner_after_transfer() {
    let original_owner: ContractAddress = 'original_owner'.try_into().unwrap();
    let new_owner: ContractAddress = 'new_owner'.try_into().unwrap();
    let dao_name: felt252 = 'TestDAO';
    let dao_description: felt252 = 'Test Description';
    let dao_quorum: felt252 = 50;
    
    let dao_core = deploy_dao_core(original_owner, dao_name, dao_description, dao_quorum);
    
    // Transfer ownership
    start_cheat_caller_address(dao_core.contract_address, original_owner);
    dao_core.transfer_ownership(new_owner);
    stop_cheat_caller_address(dao_core.contract_address);
    
    let retrieved_owner = dao_core.get_owner();
    assert!(retrieved_owner == new_owner, "Owner should be updated after transfer");
}

// ========== get_member_count Tests ==========

#[test]
fn test_dao_core_get_member_count_owner() {
    let (dao_core, _, _, _, _) = setup_dao_with_members();
    
    let owner_count = dao_core.get_member_count(MemberTier::Owner);
    assert(owner_count == 1, 'Owner count should always be 1');
}

#[test]
fn test_dao_core_get_member_count_subcommittee() {
    let (dao_core, _, _, _, _) = setup_dao_with_members();
    
    let admin_count = dao_core.get_member_count(MemberTier::SubCommittee);
    assert(admin_count == 2, 'Admin count should be 2');
}

#[test]
fn test_dao_core_get_member_count_general_member() {
    let (dao_core, _, _, _, _) = setup_dao_with_members();
    
    let member_count = dao_core.get_member_count(MemberTier::GeneralMember);
    assert!(member_count == 2, "General member count should be 2");
}

#[test]
fn test_dao_core_get_member_count_none() {
    let (dao_core, _, _, _, _) = setup_dao_with_members();
    
    let none_count = dao_core.get_member_count(MemberTier::None);
    assert(none_count == 0, 'None tier count should be 0');
}

#[test]
fn test_dao_core_get_member_count_after_additions_and_removals() {
    let (dao_core, owner, admin1, member1, _) = setup_dao_with_members();
    
    let new_admin: ContractAddress = 'new_admin'.try_into().unwrap();
    let new_member: ContractAddress = 'new_member'.try_into().unwrap();
    
    start_cheat_caller_address(dao_core.contract_address, owner);
    
    // Add one more admin and one more general member
    dao_core.add_member(new_admin, MemberTier::SubCommittee);
    dao_core.add_member(new_member, MemberTier::GeneralMember);
    
    // Verify counts increased
    assert(dao_core.get_member_count(MemberTier::SubCommittee) == 3, 'Admin count should be 3');
    assert(dao_core.get_member_count(MemberTier::GeneralMember) == 3, 'Member count should be 3');
    
    // Remove one admin and one general member
    dao_core.remove_member(admin1);
    dao_core.remove_member(member1);
    
    // Verify counts decreased
    assert(dao_core.get_member_count(MemberTier::SubCommittee) == 2, 'Admin count should be 2');
    assert(dao_core.get_member_count(MemberTier::GeneralMember) == 2, 'Member count should be 2');
    
    stop_cheat_caller_address(dao_core.contract_address);
}

// ========== get_dao_name Tests ==========

#[test]
fn test_dao_core_get_dao_name() {
    let owner: ContractAddress = 'test_owner'.try_into().unwrap();
    let dao_name: felt252 = 'SocialDAO';
    let dao_description: felt252 = 'Test Description';
    let dao_quorum: felt252 = 75;
    
    let dao_core = deploy_dao_core(owner, dao_name, dao_description, dao_quorum);
    
    let retrieved_name = dao_core.get_dao_name();
    assert!(retrieved_name == dao_name, "Retrieved name should match constructor");
}


// ========== Edge Cases and Integration Tests ==========

#[test]
fn test_dao_core_member_promotion_affects_role_correctly() {
    let owner: ContractAddress = 'owner'.try_into().unwrap();
    let member: ContractAddress = 'member'.try_into().unwrap();
    
    let dao_core = deploy_dao_core(owner, 'TestDAO', 'Description', 50);
    
    start_cheat_caller_address(dao_core.contract_address, owner);
    
    // Start as general member
    dao_core.add_member(member, MemberTier::GeneralMember);
    assert(dao_core.get_role(member) == 3_u8, 'Should be general member');
    assert(dao_core.is_member(member, MemberTier::GeneralMember), 'Should be general member');
    assert(!dao_core.is_member(member, MemberTier::SubCommittee), 'Should not be admin yet');
    
    // Promote to admin
    dao_core.add_member(member, MemberTier::SubCommittee);
    assert(dao_core.get_role(member) == 2_u8, 'Should be admin after promotion');
    assert(dao_core.is_member(member, MemberTier::SubCommittee), 'Should be admin');
    assert(!dao_core.is_member(member, MemberTier::GeneralMember), 'Should not be general member');
    
    // Verify counts are correct
    assert(dao_core.get_member_count(MemberTier::SubCommittee) == 1, 'Admin count should be 1');
    assert(dao_core.get_member_count(MemberTier::GeneralMember) == 0, 'Member count should be 0');
    
    stop_cheat_caller_address(dao_core.contract_address);
}

#[test]
fn test_dao_core_view_functions_with_zero_address() {
    let owner: ContractAddress = 'owner'.try_into().unwrap();
    let zero_address: ContractAddress = 0.try_into().unwrap();
    
    let dao_core = deploy_dao_core(owner, 'TestDAO', 'Description', 50);
    
    // Test all is_member variations with zero address
    assert(!dao_core.is_member(zero_address, MemberTier::Owner), 'Zero addr not owner');
    assert(!dao_core.is_member(zero_address, MemberTier::SubCommittee), 'Zero addr not admin');
    assert(!dao_core.is_member(zero_address, MemberTier::GeneralMember), 'Zero addr not member');
    assert(!dao_core.is_member(zero_address, MemberTier::None), 'Zero addr not none');
    
    // Test get_role with zero address
    assert(dao_core.get_role(zero_address) == 0_u8, 'Zero addr role should be 0');
}