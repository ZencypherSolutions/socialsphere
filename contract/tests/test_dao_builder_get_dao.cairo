use contract::dao_builder::{IDaoBuilderDispatcher, IDaoBuilderDispatcherTrait};
use snforge_std::{
    ContractClassTrait, DeclareResultTrait, declare, start_cheat_caller_address,
    stop_cheat_caller_address,
};
use starknet::{ContractAddress, get_block_timestamp};

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
fn test_dao_builder_get_dao_count() {
    let dao_builder = setup();

    let dispatcher = IDaoBuilderDispatcher { contract_address: dao_builder };

    start_cheat_caller_address(dao_builder, owner());

    let dao_count = dispatcher.get_dao_count();

    assert(dao_count == 0, 'Invalid dao count');

    let _ = dispatcher.create_dao(
        'Test DAO 1',
        'TD1',
        'Description1',
        'TD1',
    );

    let dao_count = dispatcher.get_dao_count();

    assert(dao_count == 1, 'Invalid dao count');

    let _ = dispatcher.create_dao(
        'Test DAO 2',
        'TD2',
        'Description2',
        'TD2',
    );

    let dao_count = dispatcher.get_dao_count();

    assert(dao_count == 2, 'Invalid dao count');

    stop_cheat_caller_address(dao_builder);
}

#[test]
fn test_dao_builder_get_dao_by_address() {
    let dao_builder = setup();

    let dispatcher = IDaoBuilderDispatcher { contract_address: dao_builder };

    start_cheat_caller_address(dao_builder, 2.try_into().unwrap());

    let empty_dao = dispatcher.get_dao_by_address(0.try_into().unwrap());
    assert(empty_dao.index == 0, 'Invalid dao index');
    assert(empty_dao.address == 0.try_into().unwrap(), 'Invalid dao address');
    assert(empty_dao.deployer == 0.try_into().unwrap(), 'Invalid dao deployer');
    assert(empty_dao.deployed_at == 0, 'Invalid dao deployed at');

    let dao_count = dispatcher.get_dao_count();

    assert(dao_count == 0, 'Invalid dao count');

    let new_dao = dispatcher.create_dao(
        'Test DAO 1',
        'TD1',
        'Description1',
        'TD1',
    );

    let dao_by_address = dispatcher.get_dao_by_address(new_dao);

    assert(dao_by_address.index == 0, 'Invalid dao index');
    assert(dao_by_address.address == new_dao, 'Invalid dao address');
    assert(dao_by_address.deployer == 2.try_into().unwrap(), 'Invalid dao deployer');
    assert(dao_by_address.deployed_at == get_block_timestamp(), 'Invalid dao deployed at');

    stop_cheat_caller_address(dao_builder);
}
