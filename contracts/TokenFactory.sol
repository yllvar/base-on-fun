// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ClankerToken.sol";
import "./StandardToken.sol";
import "./TokenRegistry.sol";
import "./interfaces/IUniswapV3Factory.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenFactory is Ownable {
    // Contract addresses
    address public tokenRegistry;
    address public uniswapFactory;
    address public wethAddress;
    
    // Platform fee in basis points (e.g., 50 = 0.5%)
    uint16 public platformFee = 50; // 0.5%
    address public feeCollector;
    
    // Events
    event TokenCreated(address indexed tokenAddress, string name, string symbol, address indexed creator, bool isClanker);
    event LiquidityAdded(address indexed tokenAddress, uint256 ethAmount, uint256 tokenAmount);
    
    constructor(address _tokenRegistry, address _uniswapFactory, address _wethAddress) Ownable(msg.sender) {
        tokenRegistry = _tokenRegistry;
        uniswapFactory = _uniswapFactory;
        wethAddress = _wethAddress;
        feeCollector = msg.sender;
    }
    
    /**
     * @dev Creates a new token and adds initial liquidity
     * @param name Token name
     * @param symbol Token symbol
     * @param totalSupply Total supply of tokens
     * @param isClanker Whether this is a Clanker token with creator fees
     * @param metadataURI URI for token metadata (description, image, etc.)
     */
    function createToken(
        string memory name,
        string memory symbol,
        uint256 totalSupply,
        bool isClanker,
        string memory metadataURI
    ) external payable returns (address) {
        require(msg.value >= 0.01 ether, "Minimum 0.01 ETH required for liquidity");
        
        // Calculate platform fee
        uint256 platformFeeAmount = (msg.value * platformFee) / 10000;
        uint256 liquidityAmount = msg.value - platformFeeAmount;
        
        // Create token
        address tokenAddress;
        if (isClanker) {
            ClankerToken token = new ClankerToken(name, symbol, totalSupply, msg.sender);
            tokenAddress = address(token);
        } else {
            StandardToken token = new StandardToken(name, symbol, totalSupply, msg.sender);
            tokenAddress = address(token);
        }
        
        // Register token
        TokenRegistry(tokenRegistry).registerToken(
            tokenAddress,
            name,
            symbol,
            msg.sender,
            isClanker,
            metadataURI
        );
        
        // Add liquidity to Uniswap
        _addLiquidity(tokenAddress, liquidityAmount, totalSupply / 2);
        
        // Transfer platform fee
        (bool sent, ) = feeCollector.call{value: platformFeeAmount}("");
        require(sent, "Failed to send platform fee");
        
        emit TokenCreated(tokenAddress, name, symbol, msg.sender, isClanker);
        
        return tokenAddress;
    }
    
    /**
     * @dev Internal function to add liquidity to Uniswap
     */
    function _addLiquidity(address tokenAddress, uint256 ethAmount, uint256 tokenAmount) internal {
        // Request tokens from creator
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), tokenAmount);
        
        // Create pool if it doesn't exist
        address pool = IUniswapV3Factory(uniswapFactory).getPool(tokenAddress, wethAddress, 3000);
        if (pool == address(0)) {
            pool = IUniswapV3Factory(uniswapFactory).createPool(tokenAddress, wethAddress, 3000);
        }
        
        // Add liquidity logic would go here
        // This is simplified - in a real implementation, you'd use the Uniswap V3 periphery contracts
        
        emit LiquidityAdded(tokenAddress, ethAmount, tokenAmount);
    }
    
    /**
     * @dev Update platform fee
     */
    function setPlatformFee(uint16 _platformFee) external onlyOwner {
        require(_platformFee <= 500, "Fee cannot exceed 5%");
        platformFee = _platformFee;
    }
    
    /**
     * @dev Update fee collector address
     */
    function setFeeCollector(address _feeCollector) external onlyOwner {
        feeCollector = _feeCollector;
    }
}
