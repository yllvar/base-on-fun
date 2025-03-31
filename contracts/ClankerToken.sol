// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ClankerToken is ERC20, Ownable {
    // Creator fee in basis points (40 = 0.4%)
    uint16 public constant CREATOR_FEE = 40;
    
    // Creator address that receives fees
    address public creator;
    
    // Fee exemptions for certain addresses (like the liquidity pool)
    mapping(address => bool) public isExemptFromFee;
    
    // Events
    event CreatorFeeCollected(address indexed from, address indexed to, uint256 amount);
    
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        address _creator
    ) ERC20(name, symbol) Ownable(_creator) {
        creator = _creator;
        
        // Exempt creator and this contract from fees
        isExemptFromFee[_creator] = true;
        isExemptFromFee[address(this)] = true;
        
        // Mint initial supply to creator
        _mint(_creator, initialSupply);
    }
    
    /**
     * @dev Override transfer function to include creator fee
     */
    function transfer(address to, uint256 amount) public override returns (bool) {
        return _transferWithFee(msg.sender, to, amount);
    }
    
    /**
     * @dev Override transferFrom function to include creator fee
     */
    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        return _transferWithFee(from, to, amount);
    }
    
    /**
     * @dev Internal function to handle transfers with fee
     */
    function _transferWithFee(address from, address to, uint256 amount) internal returns (bool) {
        // Check if either sender or recipient is exempt from fee
        if (isExemptFromFee[from] || isExemptFromFee[to]) {
            _transfer(from, to, amount);
            return true;
        }
        
        // Calculate fee
        uint256 feeAmount = (amount * CREATOR_FEE) / 10000;
        uint256 transferAmount = amount - feeAmount;
        
        // Transfer to recipient and creator
        _transfer(from, to, transferAmount);
        _transfer(from, creator, feeAmount);
        
        emit CreatorFeeCollected(from, to, feeAmount);
        
        return true;
    }
    
    /**
     * @dev Set fee exemption status for an address
     */
    function setFeeExemption(address account, bool exempt) external onlyOwner {
        isExemptFromFee[account] = exempt;
    }
    
    /**
     * @dev Update creator address
     */
    function updateCreator(address newCreator) external onlyOwner {
        require(newCreator != address(0), "New creator cannot be zero address");
        creator = newCreator;
    }
}
