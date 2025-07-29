use starknet::ContractAddress;
#[derive(Copy, Drop, Serde, starknet::Store)]
pub struct DaoConfig{
pub voting_period: u32,
pub admin: ContractAddress,
pub vote_weight_module: ContractAddress,
}