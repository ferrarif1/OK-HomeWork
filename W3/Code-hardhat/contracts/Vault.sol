// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./MDG.sol";

contract Vault is Ownable{

    
    mapping(address => uint256) balancesOfMDG;

    MDG mdgToken;
    bool public locked;
 
    modifier noReentrancy(){
      require(!locked, 'No reentrancy');
      locked = true;
      _;
      locked = false;
    }

    constructor(address mdgAddr) {
        mdgToken = MDG(mdgAddr);
    }
    //合约自我授权
    function approveMDG(uint amount)public onlyOwner{
        mdgToken.approve(address(this),amount);
    } 

    function deposit(uint amount)public{
        require(amount > 0, "amount should > 0");
        require(amount < mdgToken.totalSupply()- mdgToken.balanceOf(address(0)), "amount should < totalSupply-burned");
        bool success = mdgToken.transferFrom(msg.sender, address(this), amount);
        require(success, "mdgToken transfer error!");
        uint256 currentAmount = balancesOfMDG[msg.sender];
        mdgToken.approve(msg.sender, currentAmount+amount);
        balancesOfMDG[msg.sender] += amount;
    }

    function withdraw() external noReentrancy{
        address acc = msg.sender;
        require(balancesOfMDG[acc] > 0, "The user have no funds !");
        bool success = mdgToken.transferFrom(address(this), msg.sender, balancesOfMDG[acc]);
        require(success, "mdgToken transfer error!");
        balancesOfMDG[acc] = 0;
    }
    
    function balanceOf(address account) external view returns (uint256) {
        return balancesOfMDG[account];
    }

    fallback () external payable{
        console.log("fallback");
    }
  
    receive() external payable{
    }
}