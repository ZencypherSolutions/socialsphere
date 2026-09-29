use starknet::ContractAddress;

/// Interface that all treasury modules must implement
///
/// A DAO separates *deciding* to spend funds from *holding* them: a governance
/// module runs the vote, a treasury module custodies the assets and moves them.
/// This trait is the contract between the two halves, so any governance module
/// can drive any treasury module without knowing how that treasury stores
/// funds, which tokens it supports, or how it accounts for them.
///
/// # Security model
///
/// `execute_transfer` moves real value, so an implementation must restrict it
/// to the currently configured governance module — never to an arbitrary
/// caller. `set_governance_module` is what makes that restriction meaningful
/// and is therefore the most sensitive call in the interface: whoever can
/// change it can redirect the treasury's spending authority.
#[starknet::interface]
pub trait ITreasuryModule<TContractState> {
    /// Transfers funds out of the treasury to a recipient
    ///
    /// Called by the governance module once a spending proposal has passed.
    ///
    /// # Arguments
    /// * `token_address` - Address of the ERC20 token contract to transfer
    /// * `recipient` - Address receiving the funds
    /// * `amount` - Quantity to transfer, in the token's smallest unit
    ///
    /// # Security
    /// - Must be callable only by the configured governance module
    /// - Must reject a zero `recipient`, which would burn the funds
    /// - Must fail if the treasury's balance is insufficient, rather than
    ///   transferring a partial amount
    fn execute_transfer(
        ref self: TContractState,
        token_address: ContractAddress,
        recipient: ContractAddress,
        amount: u256,
    );

    /// Updates the governance module authorised to spend from this treasury
    ///
    /// # Arguments
    /// * `new_governance_module` - Address of the new governance contract
    ///
    /// # Security
    /// - Must be restricted to the treasury's administrator
    /// - Must reject the zero address, which would strand the treasury with no
    ///   module able to spend from it
    /// - Grants control over treasury funds, so it should follow the DAO's own
    ///   governance procedure rather than being changed unilaterally
    fn set_governance_module(ref self: TContractState, new_governance_module: ContractAddress);

    /// Returns the treasury's balance of a given token
    ///
    /// # Arguments
    /// * `token_address` - Address of the ERC20 token contract to query
    ///
    /// # Returns
    /// The amount of that token held by the treasury, in its smallest unit
    fn get_balance(self: @TContractState, token_address: ContractAddress) -> u256;
}
