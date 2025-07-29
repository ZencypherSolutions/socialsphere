# ITreasuryModule.cairo

"""
Interface for Treasury Modules.
Defines standard functions for treasury modules to interact with governance modules.
"""

@contract_interface
namespace ITreasuryModule:
    """
    Executes a transfer of funds from the treasury.
    Args:
        token_address (ContractAddress): The address of the token to transfer.
        recipient (ContractAddress): The address of the recipient.
        amount (u256): The amount to transfer.
    """
    func execute_transfer(token_address: ContractAddress, recipient: ContractAddress, amount: u256):
    end

    """
    Sets the governance module that can control this treasury.
    Args:
        new_governance_module (ContractAddress): The address of the new governance module.
    """
    func set_governance_module(new_governance_module: ContractAddress):
    end

    """
    Returns the balance of a given token in the treasury.
    Args:
        token_address (ContractAddress): The address of the token to check.
    Returns:
        u256: The balance of the token.
    """
    func get_balance(token_address: ContractAddress) -> (balance: u256):
    end
end
