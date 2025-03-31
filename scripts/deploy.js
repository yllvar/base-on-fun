const { ethers, network, hre } = require("hardhat");

async function main() {
  console.log("Starting deployment...");
  
  // Get the deployer account
  const [deployer] = await ethers.getSigners();
  console.log(`Deploying contracts with the account: ${deployer.address}`);
  
  // Deploy TokenRegistry first
  console.log("Deploying TokenRegistry...");
  const TokenRegistry = await ethers.getContractFactory("TokenRegistry");
  const tokenRegistry = await TokenRegistry.deploy();
  await tokenRegistry.deployed();
  console.log(`TokenRegistry deployed to: ${tokenRegistry.address}`);
  
  // Get Uniswap V3 Factory address for the network
  // Base uses the same addresses as Ethereum for Uniswap V3
  const uniswapV3FactoryAddress = "0x1F98431c8aD98523631AE4a59f267346ea31F984";
  const wethAddress = "0x4200000000000000000000000000000000000006"; // WETH on Base
  
  // Deploy TokenFactory
  console.log("Deploying TokenFactory...");
  const TokenFactory = await ethers.getContractFactory("TokenFactory");
  const tokenFactory = await TokenFactory.deploy(
    tokenRegistry.address,
    uniswapV3FactoryAddress,
    wethAddress
  );
  await tokenFactory.deployed();
  console.log(`TokenFactory deployed to: ${tokenFactory.address}`);
  
  // Set TokenFactory in TokenRegistry
  console.log("Setting TokenFactory in TokenRegistry...");
  const setFactoryTx = await tokenRegistry.setTokenFactory(tokenFactory.address);
  await setFactoryTx.wait();
  console.log("TokenFactory set in TokenRegistry");
  
  // Verify contracts if not on a local network
  if (network.name !== "hardhat" && network.name !== "localhost") {
    console.log("Waiting for block confirmations...");
    // Wait for 5 block confirmations to ensure the contracts are deployed
    await tokenRegistry.deployTransaction.wait(5);
    await tokenFactory.deployTransaction.wait(5);
    
    console.log("Verifying contracts on Etherscan...");
    
    // Verify TokenRegistry
    await hre.run("verify:verify", {
      address: tokenRegistry.address,
      constructorArguments: []
    });
    
    // Verify TokenFactory
    await hre.run("verify:verify", {
      address: tokenFactory.address,
      constructorArguments: [
        tokenRegistry.address,
        uniswapV3FactoryAddress,
        wethAddress
      ]
    });
  }
  
  console.log("Deployment completed!");
  
  // Return the contract addresses
  return {
    tokenRegistry: tokenRegistry.address,
    tokenFactory: tokenFactory.address
  };
}

main()
  .then((addresses) => {
    console.log("Contract addresses:");
    console.log(JSON.stringify(addresses, null, 2));
    process.exit(0);
  })
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });