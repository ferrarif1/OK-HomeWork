// SPDX-License-Identifier: MIT
// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.8.0;

import "hardhat/console.sol";


interface IScore{
    function setTeacher(address teacherAddr)external;
    function modifyScoreOfStudent(address stu,uint256 score) external;
    function scoreOf(address account) external view returns (uint256);
}

contract Teacher {

    IScore scoreContract;
    address owner;

    constructor(address scoreAddr) {
        scoreContract = IScore(scoreAddr); 
        owner = msg.sender;
        scoreContract.setTeacher(address(this));
    }

    modifier onlyOwner(){
      require(msg.sender == owner);
      _;
    }

    function modifyScore(address stuAddr, uint256 score) public onlyOwner{
        scoreContract.modifyScoreOfStudent(stuAddr, score);
    }
    
    function scoreOfStu(address stuAddr) view public returns(uint256){
        return scoreContract.scoreOf(stuAddr);
    }


    fallback () external payable{
        console.log("fallback");
        revert();
    }
  
    receive() external payable{
    }
}