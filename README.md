# Base Network Token Factory

A smart contract project for deploying custom ERC20 tokens on Base Network with automated Uniswap V3 liquidity pool creation and optional creator fees.

## Features

- Deploy ERC20 tokens on Base Network (Mainnet and Sepolia)
- Two token types:
  - Standard ERC20 tokens
  - Clanker tokens with 0.4% creator fees on transfers
- Automatic Uniswap V3 liquidity pool creation
- Token registry for tracking and verification
- Platform fee of 0.5% on token creation
- OpenZeppelin contracts v5.2.0 integration

## Prerequisites

- Node.js (v18 or later)
- npm (Node Package Manager)
- A wallet with Base Sepolia ETH for testing (get from [Base Faucet](https://www.base.org/faucet))

## Installation

1. Clone the repository:
```bash
git clone <your-repo-url>
cd <project-directory>
```

2. Install dependencies:
```bash
npm install
```

3. Create a `.env` file in the root directory:
```env
PRIVATE_KEY=your_wallet_private_key
BASE_SEPOLIA_RPC_URL=your_base_sepolia_rpc_url
BASE_MAINNET_RPC_URL=your_base_mainnet_rpc_url
ETHERSCAN_API_KEY=your_etherscan_api_key
```

## Contract Deployment

1. To deploy on Base Sepolia testnet:
```bash
npx hardhat run scripts/deploy.js --network baseSepolia
```

2. To deploy on Base mainnet:
```bash
npx hardhat run scripts/deploy.js --network baseMainnet
```

## Testing

1. Run local tests:
```bash
npx hardhat test
```

2. Test deployment on Base Sepolia:
```bash
npx hardhat run scripts/test-deployment.js --network baseSepolia
```

## Contract Addresses

- Base Sepolia (Testnet):
  - TokenRegistry: `[Your Deployed Address]`
  - TokenFactory: `[Your Deployed Address]`

- Base Mainnet:
  - TokenRegistry: `[Your Deployed Address]`
  - TokenFactory: `[Your Deployed Address]`

## Contract Verification

Contracts are automatically verified on Basescan after deployment. To manually verify:

```bash
npx hardhat verify --network baseSepolia [CONTRACT_ADDRESS] [CONSTRUCTOR_ARGS]
```

## Project Structure

```
├── contracts/
│   ├── TokenFactory.sol      # Main factory contract
│   ├── TokenRegistry.sol     # Registry for token tracking
│   ├── ClankerToken.sol      # Token with creator fees
│   └── StandardToken.sol     # Standard ERC20 token
├── scripts/
│   ├── deploy.js            # Deployment script
│   └── test-deployment.js   # Deployment testing
├── test/
│   └── Token.test.js        # Contract tests
└── hardhat.config.js        # Hardhat configuration
```

## Configuration

The project uses Hardhat for development and deployment. Key configurations:

- Solidity version: 0.8.20
- Networks: Base Mainnet and Base Sepolia
- Compiler optimization enabled with 200 runs
- OpenZeppelin contracts v5.2.0

## Gas Optimization

- Optimized compiler settings
- Efficient storage usage
- Gas-optimized transfer implementations

## Security

- OpenZeppelin contracts for standard implementations
- Owner-only administrative functions
- Fee calculations using safe math
- Verified contract source code

