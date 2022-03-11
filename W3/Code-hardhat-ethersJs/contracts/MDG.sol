// SPDX-License-Identifier: MIT
// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MDG is ERC20,Ownable{

    constructor() ERC20("MyDogGod", "MDG") {
    }

    function mint(uint256 amount) external onlyOwner{
       _mint(msg.sender, amount);
    }

   
}