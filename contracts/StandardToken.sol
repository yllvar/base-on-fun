// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StandardToken is ERC20, Ownable {
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        address creator
    ) ERC20(name, symbol) Ownable(creator) {
        // Mint initial supply to creator
        _mint(creator, initialSupply);
    }
}
