use contract::dao_core::{IDaoCoreDispatcher, IDaoCoreDispatcherTrait, MemberTier, VoteType};
use core::serde::Serde;
use snforge_std::{
    ContractClassTrait, DeclareResultTrait, declare,
    start_cheat_block_timestamp, start_cheat_caller_address, stop_cheat_caller_address,
};
use starknet::ContractAddress;

fn owner() -> ContractAddress {
    1.try_into().unwrap()
}

fn member() -> ContractAddress {
    2.try_into().unwrap()
}

fn admin() -> ContractAddress {
    3.try_into().unwrap()
}

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

fn setup_dao_with_members() -> (IDaoCoreDispatcher, ContractAddress, ContractAddress, ContractAddress) {
    let owner: ContractAddress = owner();
    let admin: ContractAddress = admin();
    let member: ContractAddress = member();
    
    let dao_name: felt252 = 'TestDAO';
    let dao_description: felt252 = 'Test DAO Description';
    let dao_quorum: felt252 = 50;
    
    let dao_core = deploy_dao_core(owner, dao_name, dao_description, dao_quorum);
    
    // Add admins (only owner can add admins)
    start_cheat_caller_address(dao_core.contract_address, owner);
    dao_core.add_member(admin, MemberTier::SubCommittee);
    
    // Add general members (owner or admin can add them)
    dao_core.add_member(member, MemberTier::GeneralMember);
    stop_cheat_caller_address(dao_core.contract_address);

    (dao_core, owner, admin, member)
}

#[test]
fn test_basic_setup() {
    // Setup
    let (dao_core, owner, admin, member) = setup_dao_with_members();
    
    // Just verify the setup works
    let owner_role = dao_core.get_role(owner);
    let admin_role = dao_core.get_role(admin);
    let member_role = dao_core.get_role(member);
    
    // Debug: Let's see what the actual roles are
    assert(owner_role == 1, 'Owner should have role 1');
    assert(admin_role == 2, 'Admin should have role 2');
    assert(member_role == 3, 'Member should have role 3');
}



#[test]
fn test_cast_vote_member_can_vote() {
    // Setup
    let (dao_core, owner, _, member) = setup_dao_with_members();
    
    // Create a proposal (only owner can create proposals)
    let current_time = 1000;
    let start_time = current_time;
    let end_time = current_time + 1000;
    start_cheat_block_timestamp(dao_core.contract_address, current_time);
    
    // Debug: Let's first check if we can create a proposal
    start_cheat_caller_address(dao_core.contract_address, owner);
    let proposal_id = dao_core.create_proposal(member, start_time, end_time);
    stop_cheat_caller_address(dao_core.contract_address);
    
    // Member should be able to vote
    start_cheat_caller_address(dao_core.contract_address, member);
    dao_core.cast_vote(proposal_id, VoteType::For);
    stop_cheat_caller_address(dao_core.contract_address);
}

#[test]
#[should_panic]
fn test_cast_vote_nonexistent_proposal() {
    // Setup
    let (dao_core, _, _, member) = setup_dao_with_members();
    
    start_cheat_caller_address(dao_core.contract_address, member);
    
    // Try to vote on a non-existent proposal
    dao_core.cast_vote(999, VoteType::For);
    stop_cheat_caller_address(dao_core.contract_address);
}

#[test]
#[should_panic]
fn test_cast_vote_before_voting_start() {
    // Setup
    let (dao_core, owner, _, member) = setup_dao_with_members();
    
    // Create a proposal that starts in the future
    let current_time = 1000;
    let future_start_time = current_time + 100;
    let end_time = future_start_time + 1000;
    start_cheat_block_timestamp(dao_core.contract_address, current_time);
    
    start_cheat_caller_address(dao_core.contract_address, owner);
    let proposal_id = dao_core.create_proposal(member, future_start_time, end_time);
    stop_cheat_caller_address(dao_core.contract_address);
    
    // Try to vote before voting starts
    start_cheat_caller_address(dao_core.contract_address, member);
    dao_core.cast_vote(proposal_id, VoteType::For);
    stop_cheat_caller_address(dao_core.contract_address);
}

#[test]
#[should_panic]
fn test_cast_vote_after_voting_end() {
    // Setup
    let (dao_core, owner, _, member) = setup_dao_with_members();
    
    // Create a proposal that has already ended
    let current_time = 2000;
    let start_time = 1000;
    let past_end_time = 1500;
    start_cheat_block_timestamp(dao_core.contract_address, current_time);
    
    start_cheat_caller_address(dao_core.contract_address, owner);
    let proposal_id = dao_core.create_proposal(member, start_time, past_end_time);
    stop_cheat_caller_address(dao_core.contract_address);
    
    // Try to vote after voting has ended
    start_cheat_caller_address(dao_core.contract_address, member);
    dao_core.cast_vote(proposal_id, VoteType::For);
    stop_cheat_caller_address(dao_core.contract_address);
}

#[test]
#[should_panic]
fn test_cast_vote_non_member() {
    // Setup
    let (dao_core, owner, _, _) = setup_dao_with_members();
    let non_member: ContractAddress = 999.try_into().unwrap();
    
    // Create a proposal
    let current_time = 1000;
    let start_time = current_time;
    let end_time = current_time + 1000;
    start_cheat_block_timestamp(dao_core.contract_address, current_time);
    
    start_cheat_caller_address(dao_core.contract_address, owner);
    let proposal_id = dao_core.create_proposal(owner, start_time, end_time);
    stop_cheat_caller_address(dao_core.contract_address);
    
    // Non-member tries to vote
    start_cheat_caller_address(dao_core.contract_address, non_member);
    dao_core.cast_vote(proposal_id, VoteType::For);
    stop_cheat_caller_address(dao_core.contract_address);
}

#[test]
#[should_panic]
fn test_cast_vote_duplicate_vote() {
    // Setup
    let (dao_core, owner, _, member) = setup_dao_with_members();
    
    // Create a proposal
    let current_time = 1000;
    let start_time = current_time;
    let end_time = current_time + 1000;
    start_cheat_block_timestamp(dao_core.contract_address, current_time);
    
    start_cheat_caller_address(dao_core.contract_address, owner);
    let proposal_id = dao_core.create_proposal(member, start_time, end_time);
    stop_cheat_caller_address(dao_core.contract_address);
    
    // First vote should succeed
    start_cheat_caller_address(dao_core.contract_address, member);
    dao_core.cast_vote(proposal_id, VoteType::For);
    
    // Second vote should fail
    dao_core.cast_vote(proposal_id, VoteType::Against);
    stop_cheat_caller_address(dao_core.contract_address);
}

#[test]
fn test_cast_vote_owner_can_vote() {
    // Setup
    let (dao_core, owner, _, _) = setup_dao_with_members();
    
    // Create a proposal
    let current_time = 1000;
    let start_time = current_time;
    let end_time = current_time + 1000;
    start_cheat_block_timestamp(dao_core.contract_address, current_time);
    
    start_cheat_caller_address(dao_core.contract_address, owner);
    let proposal_id = dao_core.create_proposal(owner, start_time, end_time);
    
    // Owner should be able to vote (caller is already set to owner)
    dao_core.cast_vote(proposal_id, VoteType::For);
    stop_cheat_caller_address(dao_core.contract_address);
}

#[test]
fn test_cast_vote_admin_can_vote() {
    // Setup
    let (dao_core, owner, admin, _) = setup_dao_with_members();
    
    // Create a proposal
    let current_time = 1000;
    let start_time = current_time;
    let end_time = current_time + 1000;
    start_cheat_block_timestamp(dao_core.contract_address, current_time);
    
    start_cheat_caller_address(dao_core.contract_address, owner);
    let proposal_id = dao_core.create_proposal(admin, start_time, end_time);
    stop_cheat_caller_address(dao_core.contract_address);
    
    // Admin should be able to vote
    start_cheat_caller_address(dao_core.contract_address, admin);
    dao_core.cast_vote(proposal_id, VoteType::For);
    stop_cheat_caller_address(dao_core.contract_address);
}

#[test]
fn test_cast_vote_all_vote_types() {
    // Setup
    let (dao_core, owner, _, member) = setup_dao_with_members();
    
    // Create proposals for each vote type
    let current_time = 1000;
    let start_time = current_time;
    let end_time = current_time + 1000;
    start_cheat_block_timestamp(dao_core.contract_address, current_time);
    
    start_cheat_caller_address(dao_core.contract_address, owner);
    let proposal1 = dao_core.create_proposal(member, start_time, end_time);
    let proposal2 = dao_core.create_proposal(member, start_time, end_time);
    let proposal3 = dao_core.create_proposal(member, start_time, end_time);
    stop_cheat_caller_address(dao_core.contract_address);
    
    // Test all vote types
    start_cheat_caller_address(dao_core.contract_address, member);
    dao_core.cast_vote(proposal1, VoteType::For);
    dao_core.cast_vote(proposal2, VoteType::Against);
    dao_core.cast_vote(proposal3, VoteType::Abstain);
    stop_cheat_caller_address(dao_core.contract_address);
}

#[test]
fn test_cast_vote_multiple_members_same_proposal() {
    // Setup
    let (dao_core, owner, admin, member) = setup_dao_with_members();
    
    // Create a proposal
    let current_time = 1000;
    let start_time = current_time;
    let end_time = current_time + 1000;
    start_cheat_block_timestamp(dao_core.contract_address, current_time);
    
    start_cheat_caller_address(dao_core.contract_address, owner);
    let proposal_id = dao_core.create_proposal(owner, start_time, end_time);
    stop_cheat_caller_address(dao_core.contract_address);
    
    // Multiple members should be able to vote on the same proposal
    start_cheat_caller_address(dao_core.contract_address, owner);
    dao_core.cast_vote(proposal_id, VoteType::For);
    stop_cheat_caller_address(dao_core.contract_address);
    
    start_cheat_caller_address(dao_core.contract_address, admin);
    dao_core.cast_vote(proposal_id, VoteType::Against);
    stop_cheat_caller_address(dao_core.contract_address);
    
    start_cheat_caller_address(dao_core.contract_address, member);
    dao_core.cast_vote(proposal_id, VoteType::Abstain);
    stop_cheat_caller_address(dao_core.contract_address);
}

#[test]
fn test_cast_vote_same_member_different_proposals() {
    // Setup
    let (dao_core, owner, _, member) = setup_dao_with_members();
    
    // Create multiple proposals
    let current_time = 1000;
    let start_time = current_time;
    let end_time = current_time + 1000;
    start_cheat_block_timestamp(dao_core.contract_address, current_time);
    
    start_cheat_caller_address(dao_core.contract_address, owner);
    let proposal1 = dao_core.create_proposal(member, start_time, end_time);
    let proposal2 = dao_core.create_proposal(member, start_time, end_time);
    let proposal3 = dao_core.create_proposal(member, start_time, end_time);
    stop_cheat_caller_address(dao_core.contract_address);
    
    // Same member should be able to vote on different proposals
    start_cheat_caller_address(dao_core.contract_address, member);
    dao_core.cast_vote(proposal1, VoteType::For);
    dao_core.cast_vote(proposal2, VoteType::Against);
    dao_core.cast_vote(proposal3, VoteType::Abstain);
    stop_cheat_caller_address(dao_core.contract_address);
}

#[test]
fn test_cast_vote_exactly_at_start_time() {
    // Setup
    let (dao_core, owner, _, member) = setup_dao_with_members();
    
    let start_time = 1000;
    let end_time = start_time + 1000;
    start_cheat_block_timestamp(dao_core.contract_address, start_time);
    
    start_cheat_caller_address(dao_core.contract_address, owner);
    let proposal_id = dao_core.create_proposal(member, start_time, end_time);
    stop_cheat_caller_address(dao_core.contract_address);
    
    // Voting should be allowed exactly at start time
    start_cheat_caller_address(dao_core.contract_address, member);
    dao_core.cast_vote(proposal_id, VoteType::For);
    stop_cheat_caller_address(dao_core.contract_address);
}

#[test]
fn test_cast_vote_exactly_at_end_time() {
    // Setup
    let (dao_core, owner, _, member) = setup_dao_with_members();
    
    let start_time = 1000;
    let end_time = start_time + 1000;
    start_cheat_block_timestamp(dao_core.contract_address, end_time);
    
    start_cheat_caller_address(dao_core.contract_address, owner);
    let proposal_id = dao_core.create_proposal(member, start_time, end_time);
    stop_cheat_caller_address(dao_core.contract_address);
    
    // Voting should be allowed exactly at end time (inclusive)
    start_cheat_caller_address(dao_core.contract_address, member);
    dao_core.cast_vote(proposal_id, VoteType::For);
    stop_cheat_caller_address(dao_core.contract_address);
}

#[test]
#[should_panic]
fn test_cast_vote_one_second_before_start() {
    // Setup
    let (dao_core, owner, _, member) = setup_dao_with_members();
    
    let start_time = 1000;
    let end_time = start_time + 1000;
    start_cheat_block_timestamp(dao_core.contract_address, start_time - 1);
    
    start_cheat_caller_address(dao_core.contract_address, owner);
    let proposal_id = dao_core.create_proposal(member, start_time, end_time);
    stop_cheat_caller_address(dao_core.contract_address);
    
    // Voting should not be allowed one second before start
    start_cheat_caller_address(dao_core.contract_address, member);
    dao_core.cast_vote(proposal_id, VoteType::For);
    stop_cheat_caller_address(dao_core.contract_address);
}

#[test]
#[should_panic]
fn test_cast_vote_one_second_after_end() {
    // Setup
    let (dao_core, owner, _, member) = setup_dao_with_members();
    
    let start_time = 1000;
    let end_time = start_time + 1000;
    start_cheat_block_timestamp(dao_core.contract_address, end_time + 1);
    
    start_cheat_caller_address(dao_core.contract_address, owner);
    let proposal_id = dao_core.create_proposal(member, start_time, end_time);
    stop_cheat_caller_address(dao_core.contract_address);
    
    // Voting should not be allowed one second after end
    start_cheat_caller_address(dao_core.contract_address, member);
    dao_core.cast_vote(proposal_id, VoteType::For);
    stop_cheat_caller_address(dao_core.contract_address);
}

#[test]
#[should_panic]
fn test_cast_vote_zero_proposal_id() {
    // Setup
    let (dao_core, _, _, member) = setup_dao_with_members();
    
    start_cheat_caller_address(dao_core.contract_address, member);
    
    // Test with zero proposal ID
    dao_core.cast_vote(0, VoteType::For);
    stop_cheat_caller_address(dao_core.contract_address);
}

#[test]
#[should_panic]
fn test_cast_vote_max_proposal_id() {
    // Setup
    let (dao_core, _, _, member) = setup_dao_with_members();
    
    start_cheat_caller_address(dao_core.contract_address, member);
    
    // Test with maximum proposal ID
    dao_core.cast_vote(18446744073709551615, VoteType::For); // u64::MAX
    stop_cheat_caller_address(dao_core.contract_address);
} 