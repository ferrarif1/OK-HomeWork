// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./MyToken.sol";
import "./WETH.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

//
contract MyTokenMarket is Ownable{
   //UniswapV2Router02
    address uv2address = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address wethaddress = 0xc778417E063141139Fce010982780140Aa0cD5Ab;
    address mytokenaddress = 0xFA7b29AC82cC25D50970D7E6d842B0e6a529BAeE;
    IUniswapV2Router02 uv2router = IUniswapV2Router02(uv2address);
    MyToken mtoken = MyToken(mytokenaddress);//0xFA7b29AC82cC25D50970D7E6d842B0e6a529BAeE
    
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


/*
uint256 amountOutMin, address[] path, address to, uint256 deadline


确认路径第一个地址为WETH
数额数组 ≈ 遍历路径数组((精确输入数额 * 储备量Out) / (储备量In * 1000 + msg.value))
确认数额数组最后一个元素>=最小输出数额
将数额数组[0]的数额存款ETH到WETH合约
断言将数额数组[0]的数额的WETH发送到路径(0,1)的pair合约地址
私有交换(数额数组,路径数组,to地址)

*/
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