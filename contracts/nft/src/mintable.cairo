#[starknet::contract]
mod MintableERC721 {
    use openzeppelin_introspection::src5::SRC5Component;
    use openzeppelin_token::erc721::{ERC721Component, ERC721HooksEmptyImpl};
    use starknet::{ContractAddress, get_caller_address};
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};

    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);

    // ERC721
    #[abi(embed_v0)]
    impl ERC721MixinImpl = ERC721Component::ERC721MixinImpl<ContractState>;
    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
        owner: ContractAddress,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC721Event: ERC721Component::Event,
        #[flat]
        SRC5Event: SRC5Component::Event,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        name: ByteArray,
        symbol: ByteArray,
        owner: ContractAddress,
    ) {
        let base_uri: ByteArray = "";
        self.owner.write(owner);
        self.erc721.initializer(name, symbol, base_uri);
    }

    fn assert_owner(self: @ContractState) {
        let caller = get_caller_address();
        assert(caller == self.owner.read(), 'NOT_OWNER');
    }

    #[external(v0)]
    fn mint(ref self: ContractState, recipient: ContractAddress, token_id: u256) {
        assert_owner(@self);
        self.erc721.mint(recipient, token_id);
    }

    #[external(v0)]
    fn owner(self: @ContractState) -> ContractAddress {
        self.owner.read()
    }
}
