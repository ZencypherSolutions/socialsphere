use contract::CustomFactor::{CustomFactor, IVoteWeightDispatcher, IVoteWeightDispatcherTrait};
use snforge_std::{
    ContractClassTrait, DeclareResultTrait, EventSpyAssertionsTrait, declare, spy_events,
    start_cheat_caller_address, stop_cheat_caller_address,
};
use starknet::ContractAddress;

const ADMIN: ContractAddress = 'admin'.try_into().unwrap();

fn deploy_contract(name: ByteArray, calldata: Array<felt252>) -> ContractAddress {
    let contract = declare(name).unwrap().contract_class();
    let (contract_address, _) = contract.deploy(@calldata).unwrap();
    contract_address
}

fn setup() -> IVoteWeightDispatcher {
    let mut calldata = array![];
    ADMIN.serialize(ref calldata);
    IVoteWeightDispatcher { contract_address: deploy_contract("CustomFactor", calldata) }
}

#[test]
fn test_set_vote_weight_by_admin() {
    let vote_weight = setup();
    let user1: ContractAddress = 'user1'.try_into().unwrap();
    let weight = 100;

    start_cheat_caller_address(vote_weight.contract_address, ADMIN);
    let mut spy = spy_events();
    vote_weight.set_weight(user1, weight);
    stop_cheat_caller_address(vote_weight.contract_address);

    // Ensure the weight is properly set
    assert(vote_weight.get_weight(user1) == weight, 'Weight not set correctly');

    // Ensure an event is emitted
    let expected_event = CustomFactor::Event::WeightSet(
        CustomFactor::WeightSet { account: user1, weight },
    );
    spy.assert_emitted(@array![(vote_weight.contract_address, expected_event)]);
}

#[test]
#[should_panic(expected: 'Caller is missing role')]
fn test_set_vote_weight_by_non_admin() {
    let vote_weight = setup();
    let user1: ContractAddress = 'user1'.try_into().unwrap();

    vote_weight.set_weight(user1, 100);
}

#[test]
#[should_panic(expected: 'Account cannot be zero')]
fn test_set_vote_weight_for_zero_address() {
    let vote_weight = setup();
    let user1: ContractAddress = 0.try_into().unwrap();

    start_cheat_caller_address(vote_weight.contract_address, ADMIN);
    vote_weight.set_weight(user1, 100);
    stop_cheat_caller_address(vote_weight.contract_address);
}

#[test]
fn test_bulk_set_vote_weight_by_admin() {
    let vote_weight = setup();
    let user1: ContractAddress = 'user1'.try_into().unwrap();
    let user2: ContractAddress = 'user2'.try_into().unwrap();
    let user3: ContractAddress = 'user3'.try_into().unwrap();

    let users: Span<ContractAddress> = array![user1, user2, user3].span();
    let weights: Span<u128> = array![100, 200, 300].span();

    start_cheat_caller_address(vote_weight.contract_address, ADMIN);
    let mut spy = spy_events();
    vote_weight.bulk_set_weights(users, weights);
    stop_cheat_caller_address(vote_weight.contract_address);

    // Ensure the weights are properly set
    assert(vote_weight.get_weight(user1) == 100, 'Weight not set correctly');
    assert(vote_weight.get_weight(user2) == 200, 'Weight not set correctly');
    assert(vote_weight.get_weight(user3) == 300, 'Weight not set correctly');

    // Ensure all events are emitted
    let expected_events = array![
        CustomFactor::Event::WeightSet(CustomFactor::WeightSet { account: user1, weight: 100 }),
        CustomFactor::Event::WeightSet(CustomFactor::WeightSet { account: user2, weight: 200 }),
        CustomFactor::Event::WeightSet(CustomFactor::WeightSet { account: user3, weight: 300 }),
    ];
    for expected_event in expected_events {
        spy.assert_emitted(@array![(vote_weight.contract_address, expected_event)]);
    }
}
