// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract MyToken is ERC20,Ownable{
   
   
    constructor() ERC20("MyToken", "MTT") {
    }

    function mint(uint256 amount) external onlyOwner{
       _mint(msg.sender, amount);
    }
}