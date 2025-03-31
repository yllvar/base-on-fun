// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenRegistry is Ownable {
    struct TokenInfo {
        address tokenAddress;
        string name;
        string symbol;
        address creator;
        bool isClanker;
        uint256 createdAt;
        string metadataURI;
        bool verified;
    }
    
    // Array of all token addresses
    address[] public allTokens;
    
    // Mapping from token address to token info
    mapping(address => TokenInfo) public tokenInfo;
    
    // Mapping from creator to their tokens
    mapping(address => address[]) public creatorTokens;
    
    // Factory address that's allowed to register tokens
    address public tokenFactory;
    
    // Events
    event TokenRegistered(address indexed tokenAddress, string name, string symbol, address indexed creator);
    event TokenVerified(address indexed tokenAddress, bool verified);
    
    constructor() Ownable(msg.sender) {}
    
    /**
     * @dev Set the token factory address
     */
    function setTokenFactory(address _tokenFactory) external onlyOwner {
        tokenFactory = _tokenFactory;
    }
    
    /**
     * @dev Register a new token (can only be called by the token factory)
     */
    function registerToken(
        address tokenAddress,
        string memory name,
        string memory symbol,
        address creator,
        bool isClanker,
        string memory metadataURI
    ) external {
        require(msg.sender == tokenFactory || msg.sender == owner(), "Only factory can register tokens");
        require(tokenInfo[tokenAddress].tokenAddress == address(0), "Token already registered");
        
        // Create token info
        TokenInfo memory info = TokenInfo({
            tokenAddress: tokenAddress,
            name: name,
            symbol: symbol,
            creator: creator,
            isClanker: isClanker,
            createdAt: block.timestamp,
            metadataURI: metadataURI,
            verified: false
        });
        
        // Store token info
        tokenInfo[tokenAddress] = info;
        allTokens.push(tokenAddress);
        creatorTokens[creator].push(tokenAddress);
        
        emit TokenRegistered(tokenAddress, name, symbol, creator);
    }
    
    /**
     * @dev Verify a token (admin function)
     */
    function verifyToken(address tokenAddress, bool verified) external onlyOwner {
        require(tokenInfo[tokenAddress].tokenAddress != address(0), "Token not registered");
        tokenInfo[tokenAddress].verified = verified;
        
        emit TokenVerified(tokenAddress, verified);
    }
    
    /**
     * @dev Update token metadata URI
     */
    function updateMetadataURI(address tokenAddress, string memory metadataURI) external {
        require(tokenInfo[tokenAddress].creator == msg.sender, "Only creator can update metadata");
        tokenInfo[tokenAddress].metadataURI = metadataURI;
    }
    
    /**
     * @dev Get all tokens
     */
    function getAllTokens() external view returns (address[] memory) {
        return allTokens;
    }
    
    /**
     * @dev Get tokens by creator
     */
    function getTokensByCreator(address creator) external view returns (address[] memory) {
        return creatorTokens[creator];
    }
    
    /**
     * @dev Get token count
     */
    function getTokenCount() external view returns (uint256) {
        return allTokens.length;
    }
}