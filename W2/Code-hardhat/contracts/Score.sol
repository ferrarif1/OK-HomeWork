// SPDX-License-Identifier: MIT
// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.8.0;

import "hardhat/console.sol";


contract Score {


    mapping(address => uint256) studentScore;
    address public teacher;
    uint256 maxScore = 100;

    bool public locked;
 
    modifier onlyTeacher(){
      console.log("only teacher, msg.sender = ", msg.sender);
      require(msg.sender == teacher);
      _;
    }

    constructor() {
        
    }

    function setTeacher(address teacherAddr)external {
        teacher = teacherAddr;
    }

    function modifyScoreOfStudent(address stu,uint256 score) external onlyTeacher{
        require(score >= 0 && score <= 100, "The score should be in [0, 100]!");
        console.log("teacher = ", teacher);
        studentScore[stu] = score;
    }
    
    function scoreOf(address account) external view returns (uint256) {
        return studentScore[account];
    }

    fallback () external payable{
        console.log("fallback");
        revert();
    }
  
    receive() external payable{
    }
}