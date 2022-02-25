// SPDX-License-Identifier: MIT
// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.7.0;
/*
在Hardhat Network上运行合约和测试时，
你可以在Solidity代码中调用console.log()打印日志信息和合约变量。
你必须先从合约代码中导入Hardhat 的console.log再使用它。
*/
import "hardhat/console.sol";

contract Token {

    string public name = "My Hardhat Token";
    string public symbol = "MBT";

    uint256 public totalSupply = 1000000;

    address public owner;

    mapping(address => uint256) balances;

    /**
     * 合约构造函数
     */
    constructor() public {
        balances[msg.sender] = totalSupply;
        owner = msg.sender;
    }

    /**
     * 代币转账.
     */
    function transfer(address to, uint256 amount) external {
        console.log("Sender balance is %s tokens", balances[msg.sender]);
        console.log("Trying to send %s tokens to %s", amount, to);
        require(balances[msg.sender] >= amount, "Not enough tokens");
        balances[msg.sender] -= amount;
        balances[to] += amount;
    }

    /**
     * 读取某账号的代币余额
     */
    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }
}