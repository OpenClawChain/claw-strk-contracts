# claw-strk-contracts

Cairo contracts for the **claw-strk** CLI, split out of the main repo.

> Target: **Starknet Sepolia** (for now).

## Packages

All contracts live under `./contracts/*` as individual Scarb packages:

- `contracts/token` — demo ERC20 tokens (fixed + mintable)
- `contracts/lend` — lending demo pool (registry + pool)
- `contracts/nft` — mintable ERC721 collection (owner-gated `mint`)
- `contracts/clawid` — `.claw` name registry (StarknetID-like MVP for Sepolia)

## Build

From the repo root, you can build each package.

### Standard

```bash
cd contracts/<package>
scarb build
```

### macOS cache-lock workaround

If you hit errors like:

- `failed to open .../.package-cache.lock ... Operation not permitted`

Use:

```bash
cd contracts/<package>
SCARB_CACHE=/tmp/scarb-cache SCARB_OFFLINE=true scarb build
```

Build artifacts are written to:

- `contracts/<package>/target/dev/*.contract_class.json`
- `contracts/<package>/target/dev/*.compiled_contract_class.json`

## Using with claw-strk

The `claw-strk` CLI expects compiled artifacts to be copied into its `assets/` folder (e.g. `claw-strk/assets/nft`, `claw-strk/assets/clawid`).

For the currently deployed Sepolia addresses and CLI usage examples, see:
- https://github.com/OpenClawChain/claw-strk/blob/main/SKILL.md


