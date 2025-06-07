use starknet::ContractAddress;
#[starknet::interface]
trait IDaoCore<TContractState> {
    // Add a member to the DAO with a specified tier.
    // Tier 1 (Owner) cannot be set via this function.
    // Tier 2 (Admin) can only be added by the current owner.
    // Tier 3 (General Member) can be added by the owner or an admin.
    // If a member is promoted to a higher tier, they are removed from lower tiers.
    // Emits a MemberAdded event.
    fn add_member(ref self: TContractState, member_address: ContractAddress, tier: MemberTier);

    // Remove a member from the DAO, regardless of their tier.
    // Only the DAO owner can remove an admin.
    // The DAO owner or a sub-committee member can remove a general member.
    // Emits a MemberRemoved event.
    fn remove_member(ref self: TContractState, member_address: ContractAddress);

    // Transfer the ownership of the DAO to a new owner.
    // This function can only be called by the current DAO Owner.
    // Emits an OwnershipTransferred event.
    fn transfer_ownership(ref self: TContractState, new_owner: ContractAddress);

    // Check if an address is a member of a specific tier.
    // Returns true if the address is in the specified tier, false otherwise.
    fn is_member(self: @TContractState, addr: ContractAddress, tier: MemberTier) -> bool;

    // Get the role/tier of a member.
    // Returns:
    //   MemberTier::Owner (1) if the address is the DAO owner.
    //   MemberTier::SubCommittee (2) if the address is an admin.
    //   MemberTier::GeneralMember (3) if the address is a general member.
    //   0 if the address is not found in any tier.
    fn get_role(self: @TContractState, addr: ContractAddress) -> u8;

    // Get the owner of the DAO.
    fn get_owner(self: @TContractState) -> ContractAddress;

    // Get the total number of members in a specific tier.
    fn get_member_count(self: @TContractState, tier: MemberTier) -> u32;

    // Get the DAO name.
    fn get_dao_name(self: @TContractState) -> felt252;
}
#[derive(Copy, Drop, PartialEq, Serde)]
enum MemberTier {
    None,
    Owner,
    SubCommittee,
    GeneralMember,
}
#[starknet::contract]
mod DaoCore {
    use starknet::storage::StorageMapReadAccess;
    use starknet::storage::StorageMapWriteAccess;
    use starknet::{ContractAddress, get_caller_address};
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess, Map};
    use super::MemberTier;
    use core::num::traits::Zero;
    use core::panic_with_felt252;


    // Events for tracking state changes
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        MemberAdded: MemberAdded,
        MemberRemoved: MemberRemoved,
        OwnershipTransferred: OwnershipTransferred,
    }

    #[derive(Drop, starknet::Event)]
    struct MemberAdded {
        #[key]
        member_address: ContractAddress,
        tier: u8,
    }

    #[derive(Drop, starknet::Event)]
    struct MemberRemoved {
        #[key]
        member_address: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct OwnershipTransferred {
        #[key]
        previous_owner: ContractAddress,
        #[key]
        new_owner: ContractAddress,
    }

    // Storage for the DAO Core contract
    #[storage]
    struct Storage {
        // Floor 1: The top-level owner of the DAO.
        owner: ContractAddress,
        // Floor 2: Mapping for sub-committee members (admins).
        admins: Map<ContractAddress, bool>,
        // Floor 3: Mapping for general members.
        members: Map<ContractAddress, bool>,
        // Optional: DAO name for identification.
        name: felt252,
        // Member counts for each tier.
        admin_count: u32,
        member_count: u32,
    }
    // Constructor for the DAO Core contract.
    // Initializes the owner (Floor 1) and the DAO name.
    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress, name: felt252) {
        assert!(!owner.is_zero(), "Owner address cannot be zero");
        self.owner.write(owner);
        self.name.write(name);
    }

    // Implementation of the IDaoCore trait
    #[abi(embed_v0)]
    impl DaoCoreImpl of super::IDaoCore<ContractState> {
        // Add a member to a specified tier.
        fn add_member(ref self: ContractState, member_address: ContractAddress, tier: MemberTier) {
            assert!(!member_address.is_zero(), "Member address cannot be zero");
            let caller = get_caller_address();

            match tier {
                MemberTier::Owner => {
                    // Owner cannot be added via this function; it's set in the constructor
                    // or via transfer_ownership.
                    panic_with_felt252('Cannot add owner via add_member');
                },
                MemberTier::SubCommittee => {
                    self._only_owner(caller); // Only owner can add admins

                    if self.admins.read(member_address) {
                        // Member is already an admin, do nothing or panic if strict.
                        // For now, we'll allow idempotent calls.
                        return;
                    }

                    // Remove from general members if they were there
                    if self.members.read(member_address) {
                        self.members.write(member_address, false);
                        self.member_count.write(self.member_count.read() - 1);
                    }

                    self.admins.write(member_address, true);
                    self.admin_count.write(self.admin_count.read() + 1);
                    self.emit(Event::MemberAdded(MemberAdded { member_address, tier: 2_u8 }));
                },
                MemberTier::GeneralMember => {
                    self
                        ._only_owner_or_sub_committee(
                            caller,
                        ); // Owner or admin can add general members

                    if self.members.read(member_address) {
                        // Member is already a general member, do nothing.
                        return;
                    }

                    // Ensure they are not an admin already (admins are implicitly members)
                    if self.admins.read(member_address) {
                        panic_with_felt252('AlreadyAdmin'.into());
                    }

                    self.members.write(member_address, true);
                    self.member_count.write(self.member_count.read() + 1);
                    self.emit(Event::MemberAdded(MemberAdded { member_address, tier: 3_u8 }));
                },
                MemberTier::None => { panic_with_felt252('Invalid tier specified'); },
            }
        }

        // Remove a member from the DAO.
        fn remove_member(ref self: ContractState, member_address: ContractAddress) {
            assert!(!member_address.is_zero(), "Member address cannot be zero");
            let caller = get_caller_address();
            let current_owner = self.owner.read();

            // Prevent owner from removing themselves directly without transferring ownership
            assert!(member_address != current_owner, "Cannot remove DAO owner directly");

            if self.admins.read(member_address) {
                // Only owner can remove admins
                self._only_owner(caller);
                self.admins.write(member_address, false);
                self.admin_count.write(self.admin_count.read() - 1);
                self.emit(Event::MemberRemoved(MemberRemoved { member_address }));
                return;
            }

            if self.members.read(member_address) {
                // Owner or sub-committee can remove general members
                self._only_owner_or_sub_committee(caller);
                self.members.write(member_address, false);
                self.member_count.write(self.member_count.read() - 1);
                self.emit(Event::MemberRemoved(MemberRemoved { member_address }));
                return;
            }

            // If member is not found in any tier, do nothing or panic if strict.
            panic_with_felt252('Member not found');
        }

        // Transfer the ownership of the DAO to a new owner.
        fn transfer_ownership(ref self: ContractState, new_owner: ContractAddress) {
            self._only_owner(get_caller_address());
            assert!(!new_owner.is_zero(), "New owner address cannot be zero");

            let previous_owner = self.owner.read();
            self.owner.write(new_owner);

            // Optionally, demote the old owner to a general member or admin if desired
            // For now, we just transfer ownership.

            self
                .emit(
                    Event::OwnershipTransferred(OwnershipTransferred { previous_owner, new_owner }),
                );
        }

        // Check if an address is a member of a specific tier.
        fn is_member(self: @ContractState, addr: ContractAddress, tier: MemberTier) -> bool {
            match tier {
                MemberTier::Owner => { self.owner.read() == addr },
                MemberTier::SubCommittee => { self.admins.read(addr) },
                MemberTier::GeneralMember => { self.members.read(addr) },
                MemberTier::None => { false } // Invalid tier for checking membership
            }
        }

        // Get the role/tier of a member.
        fn get_role(self: @ContractState, addr: ContractAddress) -> u8 {
            if self.owner.read() == addr {
                return 1_u8; // MemberTier::Owner
            }
            if self.admins.read(addr) {
                return 2_u8; // MemberTier::SubCommittee
            }
            if self.members.read(addr) {
                return 3_u8; // MemberTier::GeneralMember
            }
            0_u8 // MemberTier::None (not found)
        }

        // Get the owner of the DAO.
        fn get_owner(self: @ContractState) -> ContractAddress {
            self.owner.read()
        }

        // Get the total number of members in a specific tier.
        fn get_member_count(self: @ContractState, tier: MemberTier) -> u32 {
            match tier {
                MemberTier::Owner => { 1 }, // There's always one owner
                MemberTier::SubCommittee => { self.admin_count.read() },
                MemberTier::GeneralMember => { self.member_count.read() },
                MemberTier::None => { 0 },
            }
        }

        // Get the DAO name.
        fn get_dao_name(self: @ContractState) -> felt252 {
            self.name.read()
        }
    }

    // Internal helper functions for access control
    #[generate_trait]
    impl InternalFunctions of InternalTrait {
        fn _only_owner(self: @ContractState, caller: ContractAddress) {
            assert!(self.owner.read() == caller, "Caller is not the DAO owner");
        }

        fn _only_admin_or_owner(self: @ContractState, caller: ContractAddress) {
            let is_owner = self.owner.read() == caller;
            let is_admin = self.admins.read(caller);
            assert!(is_owner || is_admin, "Caller is not owner or sub-committee member");
        }

        // This helper is for add_member/remove_member actions where owner or sub-committee can act
        fn _only_owner_or_sub_committee(self: @ContractState, caller: ContractAddress) {
            let is_owner = self.owner.read() == caller;
            let is_admin = self.admins.read(caller);
            assert!(is_owner || is_admin, "Caller not authorized");
        }
    }
}
