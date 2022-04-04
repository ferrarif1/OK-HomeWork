// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;



contract SelfDestructTest {

 
   constructor() payable {

   }
 
   receive() external payable {}
    
   function selfdestructfor(address registerAddress) public payable {
       address payable addr = payable(address(registerAddress));
       selfdestruct(addr);
   }
}