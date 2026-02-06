use starknet::ContractAddress;

#[starknet::interface]
trait IClawIdRegistry<TContractState> {
    fn register(ref self: TContractState, label: ByteArray, addr: ContractAddress, metadata: ByteArray);
    fn resolve(self: @TContractState, label: ByteArray) -> ContractAddress;
    fn get_record(self: @TContractState, label: ByteArray) -> (ContractAddress, ContractAddress, ByteArray);
    fn set_addr(ref self: TContractState, label: ByteArray, addr: ContractAddress);
    fn set_metadata(ref self: TContractState, label: ByteArray, metadata: ByteArray);
    fn transfer(ref self: TContractState, label: ByteArray, new_owner: ContractAddress);
    fn name_of(self: @TContractState, owner: ContractAddress) -> felt252;
}

#[starknet::contract]
mod ClawIdRegistry {
    use super::IClawIdRegistry;
    use core::byte_array::ByteArrayTrait;
    use core::pedersen::pedersen;
    use core::traits::{Into, TryInto};
    use starknet::{ContractAddress, get_caller_address};
    use starknet::storage::{Map, StorageMapReadAccess, StorageMapWriteAccess};

    #[storage]
    struct Storage {
        name_owner: Map<felt252, ContractAddress>,
        name_addr: Map<felt252, ContractAddress>,
        name_metadata: Map<felt252, ByteArray>,
        addr_to_name: Map<ContractAddress, felt252>,
    }

    // Key derivation: Pedersen hash of the label's UTF-8 bytes, folded byte-by-byte.
    fn name_key(label: @ByteArray) -> felt252 {
        let mut hash: felt252 = 0;
        let mut i: usize = 0;
        let len = label.len();
        while i < len {
            let byte = label.at(i).expect('INDEX_OOB');
            hash = pedersen(hash, byte.into());
            i += 1;
        }
        hash
    }

    fn zero_address() -> ContractAddress {
        0.try_into().unwrap()
    }

    #[abi(embed_v0)]
    impl ClawIdRegistryImpl of IClawIdRegistry<ContractState> {
        fn register(ref self: ContractState, label: ByteArray, addr: ContractAddress, metadata: ByteArray) {
            assert(label.len() > 0, 'EMPTY_LABEL');

            let key = name_key(@label);
            let caller = get_caller_address();

            let owner = self.name_owner.read(key);
            assert(owner == zero_address(), 'NAME_TAKEN');

            let existing_name = self.addr_to_name.read(caller);
            assert(existing_name == 0, 'ADDR_HAS_NAME');

            self.name_owner.write(key, caller);
            self.name_addr.write(key, addr);
            self.name_metadata.write(key, metadata);
            self.addr_to_name.write(caller, key);
        }

        fn resolve(self: @ContractState, label: ByteArray) -> ContractAddress {
            let key = name_key(@label);
            self.name_addr.read(key)
        }

        fn get_record(self: @ContractState, label: ByteArray) -> (ContractAddress, ContractAddress, ByteArray) {
            let key = name_key(@label);
            let owner = self.name_owner.read(key);
            let addr = self.name_addr.read(key);
            let metadata = self.name_metadata.read(key);
            (owner, addr, metadata)
        }

        fn set_addr(ref self: ContractState, label: ByteArray, addr: ContractAddress) {
            let key = name_key(@label);
            let caller = get_caller_address();
            let owner = self.name_owner.read(key);
            assert(owner == caller, 'NOT_OWNER');

            self.name_addr.write(key, addr);
        }

        fn set_metadata(ref self: ContractState, label: ByteArray, metadata: ByteArray) {
            let key = name_key(@label);
            let caller = get_caller_address();
            let owner = self.name_owner.read(key);
            assert(owner == caller, 'NOT_OWNER');

            self.name_metadata.write(key, metadata);
        }

        fn transfer(ref self: ContractState, label: ByteArray, new_owner: ContractAddress) {
            let key = name_key(@label);
            let caller = get_caller_address();
            let owner = self.name_owner.read(key);
            assert(owner == caller, 'NOT_OWNER');

            let existing_name = self.addr_to_name.read(new_owner);
            assert(existing_name == 0, 'NEW_OWNER_HAS_NAME');

            self.name_owner.write(key, new_owner);
            self.addr_to_name.write(caller, 0);
            self.addr_to_name.write(new_owner, key);
        }

        fn name_of(self: @ContractState, owner: ContractAddress) -> felt252 {
            self.addr_to_name.read(owner)
        }
    }

}
