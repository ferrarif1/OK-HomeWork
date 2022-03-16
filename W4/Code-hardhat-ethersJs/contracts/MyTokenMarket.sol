// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./MyToken.sol";
import "./WETH.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";


contract MyTokenMarket is Ownable{
   //UniswapV2Router02
    address uv2address = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address wethaddress = 0xc778417E063141139Fce010982780140Aa0cD5Ab;
    address mytokenaddress = 0xFA7b29AC82cC25D50970D7E6d842B0e6a529BAeE;
    IUniswapV2Router02 uv2router = IUniswapV2Router02(uv2address);
    MyToken mtoken = MyToken(mytokenaddress);
    
    constructor(){
    }


    function addLiquidity(
        uint amountMyTokenDesired,
        uint amountMyTokenMin,
        uint amountETHMin
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity){
        //本合约授权给uv2router
        mtoken.approve(address(uv2router), amountMyTokenDesired);
        bool success = mtoken.transferFrom(msg.sender, address(this), amountMyTokenDesired);
        require(success, "mtoken transfer error!");
        require(msg.value > amountETHMin, "msg.value should biggger than amountETHMin");
    
        return uv2router.addLiquidityETH{value: msg.value - 100000000000000000}( 
        mytokenaddress,
        amountMyTokenDesired,
        amountMyTokenMin,
        amountETHMin,
        msg.sender,
        block.timestamp);
    }


    function buyExactTokenByETH(uint amountOutMin)public payable returns(uint[] memory amounts){
            address[] memory path = new address[](2);
            path[0] = address(wethaddress);
            path[1] = address(mytokenaddress);
        return uv2router.swapExactETHForTokens{value: msg.value - 100000000000000000}(
            amountOutMin,
            path, 
            msg.sender,
            block.timestamp);
    }
}
