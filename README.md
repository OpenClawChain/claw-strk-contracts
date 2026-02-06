# claw-strk-contracts

Smart contracts for the Claw platform, deployed on Starknet Sepolia.

## Contract Types

### Lending
Lending pool contracts for collateralized borrowing:
- **Pool**: Core lending pool logic
- **Registry**: Pool registry and management

### ClawId
On-chain identity registry for mapping human-readable labels to Starknet addresses:
- Register unique labels (usernames/domains)
- Resolve labels to addresses
- Transfer ownership of labels
- Store metadata for each identity

### ERC20 Token
Standard ERC20 token implementations:
- **Fixed Supply**: Token with fixed total supply
- **Mintable**: Token with minting capabilities

### NFT
ERC721-compatible NFT contracts:
- **Mintable**: NFT with minting functionality

## Network

All contracts are deployed on **Starknet Sepolia** testnet.

## Build

```bash
scarb build
```

