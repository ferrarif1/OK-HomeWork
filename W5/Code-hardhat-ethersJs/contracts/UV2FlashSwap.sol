// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "./uniswap/periphery/libraries/UniswapV2Library.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

// import "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import "@uniswap/swap-router-contracts/contracts/interfaces/IV3SwapRouter.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/*
V2: 1 MTT = 1 FUSD
V3: 1 MTT = 0.5 FUSD
*/


interface IUniswapV2Callee {
    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external;
}


contract UV2FlashSwap is IUniswapV2Callee {
    address UniswapV2Router02address = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address UniswapV2Factoryaddress = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address UNIV3POSaddress = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88;
    address UniswapV3Factoryaddress = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
    address SwapRouter02address = 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45;
   
    address MTTaddress = 0x1862af5148ba4B8F48d9c512865DeC136025dC25;
    address FUSDaddress = 0xE91Df3FB3a027b32432AD91a93a6a0118486AF61;
    address UV2Pairaddress = 0x69AAbcC32124Ff3d3aCe6d6CD1808e33EC4F9b37;//V2 pair
    uint256 UV3tokenId = 16562;
    

    IUniswapV2Router02 uv2router = IUniswapV2Router02(UniswapV2Router02address);//exchange v2 
    IUniswapV2Factory uv2factory = IUniswapV2Factory(UniswapV2Factoryaddress);
    IV3SwapRouter uv3router = IV3SwapRouter(SwapRouter02address);//exchange v3 multicall(uint256 deadline, bytes[] data) deadline：1648969613
    IERC20 MTT = IERC20(MTTaddress);
    IERC20 FUSD = IERC20(FUSDaddress);
    
    IUniswapV2Pair uv2pair = IUniswapV2Pair(UV2Pairaddress);


    constructor() {
    }


    function testFlashLoan(address _tokenBorrow, uint256 _amount)public{
        MTT.approve(address(this), uint(100000000000000000000000000));
        FUSD.approve(address(this), uint(100000000000000000000000000));
        MTT.approve(address(uv2router), uint(100000000000000000000000000));
        FUSD.approve(address(uv2router), uint(100000000000000000000000000));
        MTT.approve(address(uv3router), uint(100000000000000000000000000));
        FUSD.approve(address(uv3router), uint(100000000000000000000000000));
      
        address token0 = uv2pair.token0();
        address token1 = uv2pair.token1();
        uint256 amount0Out = _tokenBorrow == token0 ? _amount : 0;
        uint256 amount1Out = _tokenBorrow == token1 ? _amount : 0;

        if(_tokenBorrow == MTTaddress){
            bool success1 = MTT.transferFrom(msg.sender, address(this), _amount);
            require(success1, "MTT transfer error!");
        }else{
            bool success2 = FUSD.transferFrom(msg.sender, address(this), _amount);
            require(success2, "FUSD transfer error!");
        }

        //V2:0.1 MTT->0.1 FUSD
        bytes memory data = abi.encode(MTTaddress, _amount);
        IUniswapV2Pair(uv2pair).swap(amount0Out, amount1Out, address(this), data);
    }

    
    /*
    V2:1 MTT->1 FUSD
    V3:1FUSD->1.xMTT
    1 MTT -> V2 
    0.x MTT->sender
    */

    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external override {
        //assert(msg.sender == UV2Pairaddress);//ensure that msg.sender is actually a V2 pair
        //console.log("msg.sender = ",msg.sender);
        //assert(amount0 == 0 || amount1 == 0); 
        // require(amount0 == 0 || amount1 == 0, "amount0 == 0 || amount1 == 0");
       console.log("amount1 = ",amount1);


       address token0 = IUniswapV2Pair(msg.sender).token0();
       address token1 = IUniswapV2Pair(msg.sender).token1();
       require(msg.sender == UV2Pairaddress, "msg.sender != UV2Pairaddress");
       require(sender == address(this), "ensure that msg.sender is actually a V2 pair");

       (address tokenBorrow, uint256 amount) = abi.decode(data, (address, uint256));

       uint256 fee = ((amount * 3) / 997) + 1;
       uint256 amountRequired = amount + fee;

        address[] memory path = new address[](2);
        path[0] = address(token0);
        path[1] = address(token1);
        
        
        /*
         struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another token
    /// @dev Setting `amountIn` to 0 will cause the contract to look up its own balance,
    /// and swap the entire amount, enabling contracts to send tokens before calling this function.
    /// @param params The parameters necessary for the swap, encoded as `ExactInputSingleParams` in calldata
    /// @return amountOut The amount of the received token
        */
        //  uint amountOut = UniswapV2Library.getAmountsIn(UniswapV2Factoryaddress, amount, path)[0];
        uint256 amountReceived;
        uint256 amountin = amountRequired - 3000;
        if(amount0 > 0){
           IV3SwapRouter.ExactInputSingleParams memory param = IV3SwapRouter.ExactInputSingleParams(FUSDaddress, MTTaddress, 3000, address(this), amountin, 0, 0);
           amountReceived = uv3router.exactInputSingle(param);
        }else{
           IV3SwapRouter.ExactInputSingleParams memory param = IV3SwapRouter.ExactInputSingleParams(MTTaddress, FUSDaddress, 3000, address(this), amountin, 0, 0);
           amountReceived = uv3router.exactInputSingle(param);
        }
       // IERC20(tokenBorrow).transfer(UV2Pairaddress, amountRequired);
        IERC20(tokenBorrow).transfer(sender, amountReceived-amountRequired);
    }


}
