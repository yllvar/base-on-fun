require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

const PRIVATE_KEY = process.env.PRIVATE_KEY;
const BASE_SEPOLIA_RPC_URL = process.env.BASE_SEPOLIA_RPC_URL || "https://sepolia.base.org";
const BASE_MAINNET_RPC_URL = process.env.BASE_MAINNET_RPC_URL || "https://mainnet.base.org";
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.20",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      }
    ]
  },
  networks: {
    // Local development
    hardhat: {
      chainId: 31337
    },
    // Base Sepolia (testnet)
    baseSepolia: {
      url: BASE_SEPOLIA_RPC_URL,
      accounts: PRIVATE_KEY ? [PRIVATE_KEY] : [],
      chainId: 84532
    },
    // Base Mainnet
    baseMainnet: {
      url: BASE_MAINNET_RPC_URL,
      accounts: PRIVATE_KEY ? [PRIVATE_KEY] : [],
      chainId: 8453,
      gasPrice: 1000000000 // 1 gwei
    }
  },
  etherscan: {
    apiKey: {
      // Base uses Etherscan API key
      baseMainnet: ETHERSCAN_API_KEY,
      baseSepolia: ETHERSCAN_API_KEY
    },
    customChains: [
      {
        network: "baseMainnet",
        chainId: 8453,
        urls: {
          apiURL: "https://api.basescan.org/api",
          browserURL: "https://basescan.org"
        }
      },
      {
        network: "baseSepolia",
        chainId: 84532,
        urls: {
          apiURL: "https://api-sepolia.basescan.org/api",
          browserURL: "https://sepolia.basescan.org"
        }
      }
    ]
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  }
};
