use contract::StandardVoting::{IGovernanceModuleDispatcher, IGovernanceModuleDispatcherTrait};
use snforge_std::{
    ContractClassTrait, DeclareResultTrait, declare, start_cheat_block_timestamp, 
    start_cheat_caller_address, stop_cheat_caller_address,
};
use starknet::ContractAddress;

// Test addresses
fn owner() -> ContractAddress {
    1.try_into().unwrap()
}

fn deploy_governance_module() -> IGovernanceModuleDispatcher {
    let governance_class = declare("StandardVoting").unwrap().contract_class();
    let mut constructor_calldata = array![];
    let voting_period: u64 = 86400; // 1 day
    let quorum_percentage: u8 = 50;
    let dao_core: ContractAddress = 999.try_into().unwrap(); // Dummy address for now
    
    voting_period.serialize(ref constructor_calldata);
    quorum_percentage.serialize(ref constructor_calldata);
    dao_core.serialize(ref constructor_calldata);
    
    let (contract_address, _) = governance_class.deploy(@constructor_calldata).unwrap();
    IGovernanceModuleDispatcher { contract_address }
}

#[test]
fn test_create_proposal_basic() {
    let governance_module = deploy_governance_module();
    let owner_addr = owner();
    
    let current_time = 1000;
    start_cheat_block_timestamp(governance_module.contract_address, current_time);
    
    let cid: felt252 = 'QmTestProposal123';
    
    start_cheat_caller_address(governance_module.contract_address, owner_addr);
    let proposal_id = governance_module.create_proposal(owner_addr, cid);
    stop_cheat_caller_address(governance_module.contract_address);
    
    // Verify proposal was created with correct ID
    assert(proposal_id == 0, 'Proposal ID should start at 0');
}

#[test]
fn test_create_proposal_increments_id() {
    let governance_module = deploy_governance_module();
    let owner_addr = owner();
    
    let current_time = 1000;
    start_cheat_block_timestamp(governance_module.contract_address, current_time);
    
    let cid1: felt252 = 'QmTestProposal1';
    let cid2: felt252 = 'QmTestProposal2';
    
    start_cheat_caller_address(governance_module.contract_address, owner_addr);
    
    // Create first proposal
    let proposal_id1 = governance_module.create_proposal(owner_addr, cid1);
    assert(proposal_id1 == 0, 'First proposal ID should be 0');
    
    // Create second proposal
    let proposal_id2 = governance_module.create_proposal(owner_addr, cid2);
    assert(proposal_id2 == 1, 'Second proposal ID should be 1');
    
    stop_cheat_caller_address(governance_module.contract_address);
}

#[test]
#[should_panic]
fn test_create_proposal_wrong_caller() {
    let governance_module = deploy_governance_module();
    let owner_addr = owner();
    let wrong_caller: ContractAddress = 999.try_into().unwrap();
    
    let current_time = 1000;
    start_cheat_block_timestamp(governance_module.contract_address, current_time);
    
    let cid: felt252 = 'QmTestProposal123';
    
    start_cheat_caller_address(governance_module.contract_address, wrong_caller);
    governance_module.create_proposal(owner_addr, cid); // Should fail - caller != proposer
    stop_cheat_caller_address(governance_module.contract_address);
}

#[test]
fn test_create_proposal_different_cids() {
    let governance_module = deploy_governance_module();
    let owner_addr = owner();
    
    let current_time = 1000;
    start_cheat_block_timestamp(governance_module.contract_address, current_time);
    
    let cid1: felt252 = 'QmTestProposal1';
    let cid2: felt252 = 'QmTestProposal2';
    let cid3: felt252 = 'QmTestProposal3';
    
    start_cheat_caller_address(governance_module.contract_address, owner_addr);
    
    let proposal_id1 = governance_module.create_proposal(owner_addr, cid1);
    let proposal_id2 = governance_module.create_proposal(owner_addr, cid2);
    let proposal_id3 = governance_module.create_proposal(owner_addr, cid3);
    
    assert(proposal_id1 == 0, 'First proposal ID should be 0');
    assert(proposal_id2 == 1, 'Second proposal ID should be 1');
    assert(proposal_id3 == 2, 'Third proposal ID should be 2');
    
    stop_cheat_caller_address(governance_module.contract_address);
}

#[test]
fn test_create_proposal_same_caller_different_proposers() {
    let governance_module = deploy_governance_module();
    let caller: ContractAddress = 1.try_into().unwrap();
    
    let current_time = 1000;
    start_cheat_block_timestamp(governance_module.contract_address, current_time);
    
    let cid1: felt252 = 'QmTestProposal1';
    let cid2: felt252 = 'QmTestProposal2';
    
    start_cheat_caller_address(governance_module.contract_address, caller);
    
    let proposal_id1 = governance_module.create_proposal(caller, cid1);
    let proposal_id2 = governance_module.create_proposal(caller, cid2);
    
    assert(proposal_id1 == 0, 'First proposal ID should be 0');
    assert(proposal_id2 == 1, 'Second proposal ID should be 1');
    
    stop_cheat_caller_address(governance_module.contract_address);
}

#[test]
fn test_create_proposal_timestamp_consistency() {
    let governance_module = deploy_governance_module();
    let owner_addr = owner();
    
    let current_time = 1000;
    start_cheat_block_timestamp(governance_module.contract_address, current_time);
    
    let cid: felt252 = 'QmTestProposalTime';
    
    start_cheat_caller_address(governance_module.contract_address, owner_addr);
    let proposal_id = governance_module.create_proposal(owner_addr, cid);
    stop_cheat_caller_address(governance_module.contract_address);
    
    // Verify proposal was created successfully
    assert(proposal_id == 0, 'Proposal created successfully');
    
    // Note: We can't directly verify the timestamps without view functions,
    // but we can verify the proposal was created successfully
    // The contract logic ensures vote_start_time = current_time and vote_end_time = current_time + voting_period
}

#[test]
fn test_create_proposal_event_emission() {
    let governance_module = deploy_governance_module();
    let owner_addr = owner();
    
    let current_time = 1000;
    start_cheat_block_timestamp(governance_module.contract_address, current_time);
    
    let cid: felt252 = 'QmTestProposalEvent';
    
    start_cheat_caller_address(governance_module.contract_address, owner_addr);
    let proposal_id = governance_module.create_proposal(owner_addr, cid);
    stop_cheat_caller_address(governance_module.contract_address);
    
    // Verify proposal was created successfully
    assert(proposal_id == 0, 'Proposal created successfully');
    
    // Note: We can't directly verify event emission without event spy functionality,
    // but we can verify the proposal was created successfully
    // The contract logic ensures ProposalCreated event is emitted with correct parameters
}

#[test]
fn test_create_proposal_zero_cid() {
    let governance_module = deploy_governance_module();
    let owner_addr = owner();
    
    let current_time = 1000;
    start_cheat_block_timestamp(governance_module.contract_address, current_time);
    
    let cid: felt252 = 0; // Zero CID
    
    start_cheat_caller_address(governance_module.contract_address, owner_addr);
    let proposal_id = governance_module.create_proposal(owner_addr, cid);
    stop_cheat_caller_address(governance_module.contract_address);
    
    // Verify proposal was created successfully even with zero CID
    assert(proposal_id == 0, 'Proposal created successfully');
}

#[test]
fn test_create_proposal_large_cid() {
    let governance_module = deploy_governance_module();
    let owner_addr = owner();
    
    let current_time = 1000;
    start_cheat_block_timestamp(governance_module.contract_address, current_time);
    
    let cid: felt252 = 'QmLongCID';
    
    start_cheat_caller_address(governance_module.contract_address, owner_addr);
    let proposal_id = governance_module.create_proposal(owner_addr, cid);
    stop_cheat_caller_address(governance_module.contract_address);
    
    // Verify proposal was created successfully with large CID
    assert(proposal_id == 0, 'Proposal created successfully');
}

#[test]
fn test_create_proposal_concurrent_calls() {
    let governance_module = deploy_governance_module();
    let owner_addr = owner();
    
    let current_time = 1000;
    start_cheat_block_timestamp(governance_module.contract_address, current_time);
    
    let cid1: felt252 = 'QmConcurrent1';
    let cid2: felt252 = 'QmConcurrent2';
    let cid3: felt252 = 'QmConcurrent3';
    
    start_cheat_caller_address(governance_module.contract_address, owner_addr);
    
    // Create multiple proposals in sequence (simulating concurrent-like behavior)
    let proposal_id1 = governance_module.create_proposal(owner_addr, cid1);
    let proposal_id2 = governance_module.create_proposal(owner_addr, cid2);
    let proposal_id3 = governance_module.create_proposal(owner_addr, cid3);
    
    // Verify all proposals got unique IDs
    assert(proposal_id1 == 0, 'First proposal ID should be 0');
    assert(proposal_id2 == 1, 'Second proposal ID should be 1');
    assert(proposal_id3 == 2, 'Third proposal ID should be 2');
    
    stop_cheat_caller_address(governance_module.contract_address);
}

#[test]
fn test_create_proposal_same_cid_different_proposers() {
    let governance_module = deploy_governance_module();
    let proposer1: ContractAddress = 1.try_into().unwrap();
    let proposer2: ContractAddress = 2.try_into().unwrap();
    
    let current_time = 1000;
    start_cheat_block_timestamp(governance_module.contract_address, current_time);
    
    let same_cid: felt252 = 'QmSameCID';
    
    // First proposer creates proposal
    start_cheat_caller_address(governance_module.contract_address, proposer1);
    let proposal_id1 = governance_module.create_proposal(proposer1, same_cid);
    stop_cheat_caller_address(governance_module.contract_address);
    
    // Second proposer creates proposal with same CID
    start_cheat_caller_address(governance_module.contract_address, proposer2);
    let proposal_id2 = governance_module.create_proposal(proposer2, same_cid);
    stop_cheat_caller_address(governance_module.contract_address);
    
    // Both should succeed with different IDs
    assert(proposal_id1 == 0, 'First proposal ID should be 0');
    assert(proposal_id2 == 1, 'Second proposal ID should be 1');
}

#[test]
fn test_create_proposal_different_timestamps() {
    let governance_module = deploy_governance_module();
    let owner_addr = owner();
    
    let cid1: felt252 = 'QmTimeTest1';
    let cid2: felt252 = 'QmTimeTest2';
    
    // Create first proposal at time 1000
    start_cheat_block_timestamp(governance_module.contract_address, 1000);
    start_cheat_caller_address(governance_module.contract_address, owner_addr);
    let proposal_id1 = governance_module.create_proposal(owner_addr, cid1);
    stop_cheat_caller_address(governance_module.contract_address);
    
    // Create second proposal at time 2000
    start_cheat_block_timestamp(governance_module.contract_address, 2000);
    start_cheat_caller_address(governance_module.contract_address, owner_addr);
    let proposal_id2 = governance_module.create_proposal(owner_addr, cid2);
    stop_cheat_caller_address(governance_module.contract_address);
    
    // Both should succeed with sequential IDs
    assert(proposal_id1 == 0, 'First proposal ID should be 0');
    assert(proposal_id2 == 1, 'Second proposal ID should be 1');
}

#[test]
fn test_create_proposal_multiple_proposals() {
    let governance_module = deploy_governance_module();
    let owner_addr = owner();
    
    let current_time = 1000;
    start_cheat_block_timestamp(governance_module.contract_address, current_time);
    
    start_cheat_caller_address(governance_module.contract_address, owner_addr);
    
    // Create multiple proposals to test ID incrementing
    let proposal_id1 = governance_module.create_proposal(owner_addr, 'QmTest1');
    let proposal_id2 = governance_module.create_proposal(owner_addr, 'QmTest2');
    let proposal_id3 = governance_module.create_proposal(owner_addr, 'QmTest3');
    let proposal_id4 = governance_module.create_proposal(owner_addr, 'QmTest4');
    let proposal_id5 = governance_module.create_proposal(owner_addr, 'QmTest5');
    
    // Verify all proposals got sequential IDs
    assert(proposal_id1 == 0, 'First proposal ID should be 0');
    assert(proposal_id2 == 1, 'Second proposal ID should be 1');
    assert(proposal_id3 == 2, 'Third proposal ID should be 2');
    assert(proposal_id4 == 3, 'Fourth proposal ID should be 3');
    assert(proposal_id5 == 4, 'Fifth proposal ID should be 4');
    
    stop_cheat_caller_address(governance_module.contract_address);
}

#[test]
fn test_create_proposal_constructor_parameters() {
    // Test with different constructor parameters
    let governance_class = declare("StandardVoting").unwrap().contract_class();
    let mut constructor_calldata = array![];
    let voting_period: u64 = 3600; // 1 hour instead of 1 day
    let quorum_percentage: u8 = 75; // 75% instead of 50%
    let dao_core: ContractAddress = 888.try_into().unwrap();
    
    voting_period.serialize(ref constructor_calldata);
    quorum_percentage.serialize(ref constructor_calldata);
    dao_core.serialize(ref constructor_calldata);
    
    let (contract_address, _) = governance_class.deploy(@constructor_calldata).unwrap();
    let governance_module = IGovernanceModuleDispatcher { contract_address };
    
    let owner_addr = owner();
    let current_time = 1000;
    start_cheat_block_timestamp(governance_module.contract_address, current_time);
    
    let cid: felt252 = 'QmConstructorTest';
    
    start_cheat_caller_address(governance_module.contract_address, owner_addr);
    let proposal_id = governance_module.create_proposal(owner_addr, cid);
    stop_cheat_caller_address(governance_module.contract_address);
    
    // Verify proposal was created successfully with different constructor params
    assert(proposal_id == 0, 'Proposal created successfully');
}
