use contract::dao_builder::{DAOCreationState, IDaoBuilderDispatcher, IDaoBuilderDispatcherTrait};
use snforge_std::{
    ContractClassTrait, DeclareResultTrait, declare, start_cheat_caller_address,
    stop_cheat_caller_address,
};
use starknet::ContractAddress;
// use contract::dao_core::{IDaoCore, IDaoCoreDispatcher, IDaoCoreDispatcherTrait};
use contract::types::DaoConfig;

fn owner() -> ContractAddress {
    1.try_into().unwrap()
}

fn setup() -> ContractAddress {
    let declare_result = declare("DaoBuilder");
    let core_class_hash = declare("DaoCore").unwrap().contract_class().class_hash;

    assert(declare_result.is_ok(), 'dao-builder declaration failed');

    let contract_class = declare_result.unwrap().contract_class();

    let mut calldata = array![];

    core_class_hash.serialize(ref calldata);
    owner().serialize(ref calldata);

    let deploy_result = contract_class.deploy(@calldata);

    assert(deploy_result.is_ok(), 'contract deployment failed');

    let (contract_address, _) = deploy_result.unwrap();
    contract_address
}

#[test]
fn test_dao_builder_constructor() {
    let dao_builder = setup();

    let core_class_hash = declare("DaoCore").unwrap().contract_class().class_hash;

    let dispatcher = IDaoBuilderDispatcher { contract_address: dao_builder };

    start_cheat_caller_address(dao_builder, owner());

    let dao_count = dispatcher.get_dao_count();
    let dao_creation_state = dispatcher.get_dao_creation_state();
    let core_hash = dispatcher.get_core_hash();
    let current_owner = dispatcher.get_owner();

    assert(dao_creation_state == DAOCreationState::CREATIONRESUMED, 'Invalid dao creation state');
    assert(dao_count == 0, 'Invalid dao count');
    assert(current_owner == owner(), 'Invalid owner');
    assert(core_hash == *core_class_hash, 'Invalid core hash');

    stop_cheat_caller_address(dao_builder);
}

#[test]
#[should_panic(expected: 'Caller is not the owner')]
fn test_dao_builder_constructor_must_panic() {
    let dao_builder = setup();

    let dao_core_class_hash_expected = declare("DaoCore").unwrap().contract_class().class_hash;

    let dispatcher = IDaoBuilderDispatcher { contract_address: dao_builder };

    start_cheat_caller_address(dao_builder, 2.try_into().unwrap());

    let dao_count = dispatcher.get_dao_count();
    let dao_creation_state = dispatcher.get_dao_creation_state();
    let core_hash = dispatcher.get_core_hash();
    let current_owner = dispatcher.get_owner();

    assert(dao_creation_state == DAOCreationState::CREATIONRESUMED, 'Invalid dao creation state');
    assert(dao_count == 0, 'Invalid dao count');
    assert(current_owner == owner(), 'Invalid owner');
    assert(core_hash == *dao_core_class_hash_expected, 'Invalid core hash');

    stop_cheat_caller_address(dao_builder);
}

#[test]
fn test_dao_config_values_are_stored() {
    use contract::dao_builder::IDaoBuilderDispatcher;
    use starknet::ContractAddress;
    use contract::types::DaoConfig;

    
    let voting_period: u32 = 42;
    let admin: ContractAddress = 1234.try_into().unwrap();
    let vote_weight_module: ContractAddress = 5678.try_into().unwrap();

    let config = DaoConfig {
        voting_period,
        admin,
        vote_weight_module,
    };

 
    let declare_result = declare("DaoBuilder");
    let core_class_hash = declare("DaoCore").unwrap().contract_class().class_hash;
    assert(declare_result.is_ok(), 'dao-builder declaration failed');
    let contract_class = declare_result.unwrap().contract_class();

    let mut calldata = array![];
    core_class_hash.serialize(ref calldata);
    admin.serialize(ref calldata); 
    config.serialize(ref calldata);

    let deploy_result = contract_class.deploy(@calldata);
    assert(deploy_result.is_ok(), 'contract deployment failed');
    let (contract_address, _) = deploy_result.unwrap();

    let dispatcher = IDaoBuilderDispatcher { contract_address };

   
    let stored_voting_period = dispatcher.get_voting_period();
    let stored_admin = dispatcher.get_admin();
    let stored_vote_weight_module = dispatcher.get_vote_weight_module();

    assert(stored_voting_period == voting_period, 'Voting period not stored correctly');
    assert(stored_admin == admin, 'Admin not stored correctly');
    assert(stored_vote_weight_module == vote_weight_module, 'Vote weight module not stored correctly');
}
