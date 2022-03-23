// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FakeUSD is ERC20{
   
   
    constructor() ERC20("FakeUSD", "FUSD") {
        _mint(msg.sender, 1000000000000000000);
    }

    function mint(uint256 amount) external{
       _mint(msg.sender, amount);
    }
}