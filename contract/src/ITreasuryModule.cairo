
// ITreasuryModule.cairo
// Cairo 1 interface for Treasury Modules

#[starknet::interface]
trait ITreasuryModule {
    /// Executes a transfer of funds from the treasury.
    ///
    /// Args:
    ///     * `token_address` - The address of the token to transfer.
    ///     * `recipient` - The address of the recipient.
    ///     * `amount` - The amount to transfer.
    fn execute_transfer(
        ref self: ContractState,
        token_address: ContractAddress,
        recipient: ContractAddress,
        amount: u256
    );

    /// Sets the governance module that can control this treasury.
    ///
    /// Args:
    ///     * `new_governance_module` - The address of the new governance module.
    fn set_governance_module(
        ref self: ContractState,
        new_governance_module: ContractAddress
    );

    /// Returns the balance of a given token in the treasury.
    ///
    /// Args:
    ///     * `token_address` - The address of the token to check.
    ///
    /// Returns:
    ///     * `u256` - The balance of the token.
    fn get_balance(
        self: @ContractState,
        token_address: ContractAddress
    ) -> u256;
}
