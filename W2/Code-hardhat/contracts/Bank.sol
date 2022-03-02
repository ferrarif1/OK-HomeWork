// SPDX-License-Identifier: MIT
// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Bank {


    mapping(address => uint256) balances;
    address public owner;
 
    constructor() {
        owner = msg.sender;
    }

    function withdraw() external{
        address acc = msg.sender;
        require(balances[acc] > 0, "The user have no funds !");
        payable(acc).transfer(balances[acc]);
    }
    
    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    fallback () external payable{
        console.log("fallback");
    }
  
    receive() external payable{
      balances[msg.sender] += msg.value;
    }
}