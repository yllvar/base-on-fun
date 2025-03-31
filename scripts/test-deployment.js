const { ethers } = require("hardhat");

// Replace these with your deployed contract addresses
const TOKEN_FACTORY_ADDRESS = "your_token_factory_address";
const TOKEN_REGISTRY_ADDRESS = "your_token_registry_address";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(`Testing with account: ${deployer.address}`);
  
  // Connect to deployed contracts
  const tokenFactory = await ethers.getContractAt("TokenFactory", TOKEN_FACTORY_ADDRESS);
  const tokenRegistry = await ethers.getContractAt("TokenRegistry", TOKEN_REGISTRY_ADDRESS);
  
  // Create a test token
  console.log("Creating a test token...");
  const tokenName = "Test Token";
  const tokenSymbol = "TEST";
  const totalSupply = ethers.utils.parseUnits("1000000", 18); // 1 million tokens
  const isClanker = true;
  const metadataURI = "ipfs://test";
  
  // Send transaction with 0.1 ETH for liquidity
  const tx = await tokenFactory.createToken(
    tokenName,
    tokenSymbol,
    totalSupply,
    isClanker,
    metadataURI,
    { value: ethers.utils.parseEther("0.1") }
  );
  
  console.log(`Transaction hash: ${tx.hash}`);
  const receipt = await tx.wait();
  console.log("Token created!");
  
  // Find the TokenCreated event to get the token address
  const tokenCreatedEvent = receipt.events.find(event => event.event === "TokenCreated");
  const tokenAddress = tokenCreatedEvent.args.tokenAddress;
  console.log(`Token address: ${tokenAddress}`);
  
  // Get token info from registry
  const info = await tokenRegistry.tokenInfo(tokenAddress);
  console.log("Token info:", {
    name: info.name,
    symbol: info.symbol,
    creator: info.creator,
    isClanker: info.isClanker,
    createdAt: new Date(info.createdAt.toNumber() * 1000).toISOString(),
    metadataURI: info.metadataURI,
    verified: info.verified
  });
  
  console.log("Test completed successfully!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });