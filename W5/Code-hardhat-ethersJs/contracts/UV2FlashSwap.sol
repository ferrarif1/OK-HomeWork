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
      
        MTT.approve(address(uv2router), uint(100000000000000000000000000));
        FUSD.approve(address(uv2router), uint(100000000000000000000000000));
        MTT.approve(address(uv3router), uint(100000000000000000000000000));
        FUSD.approve(address(uv3router), uint(100000000000000000000000000));
      
        address token0 = uv2pair.token0();
        address token1 = uv2pair.token1();
        uint256 amount0Out = _tokenBorrow == token0 ? _amount : 0;
        uint256 amount1Out = _tokenBorrow == token1 ? _amount : 0;

        //V2:0.1 MTT->0.1 FUSD
        bytes memory data = abi.encode(_tokenBorrow, _amount);
        IUniswapV2Pair(uv2pair).swap(amount0Out, amount1Out, address(this), data);
    }

    
    /*
    V2:1 MTT->1 FUSD
    V3:1FUSD->1.xMTT
    1 MTT -> V2 
    0.x MTT->sender
    */

    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external override {

       console.log("amount0,amount1 = ",amount0,amount1);

       require(msg.sender == UV2Pairaddress, "msg.sender != UV2Pairaddress");
       require(sender == address(this), "ensure that msg.sender is actually a V2 pair");

       (address tokenBorrow, uint256 amount) = abi.decode(data, (address, uint256));
        address[] memory path = new address[](2);
        uint amountMTT;
        uint amountFUSD;
        address token0 = IUniswapV2Pair(msg.sender).token0();
        address token1 = IUniswapV2Pair(msg.sender).token1();
        assert(amount0 == 0 || amount1 == 0);
        path[0] = amount0 == 0 ? token0 : token1;
        path[1] = amount0 == 0 ? token1 : token0;
        amountMTT = token0 == address(MTTaddress) ? amount0 : amount1;
        amountFUSD = token0 == address(FUSDaddress) ? amount0 : amount1;
        //https://docs.uniswap.org/protocol/V2/reference/smart-contracts/library
        uint amountShouldIN;
        uint256 amountReceived;

        if(amountFUSD > 0){
           FUSD.approve(address(SwapRouter02address), uint(100000000000000000000000000));
           amountShouldIN = UniswapV2Library.getAmountsIn(UniswapV2Factoryaddress, amountFUSD, path)[0];//MTT数量
           IV3SwapRouter.ExactInputSingleParams memory param = IV3SwapRouter.ExactInputSingleParams(FUSDaddress, MTTaddress, 3000, address(this), amount, 0, 0);
           amountReceived = uv3router.exactInputSingle(param);
           tokenBorrow = MTTaddress;
        }else{
           MTT.approve(address(SwapRouter02address), uint(100000000000000000000000000));
           amountShouldIN = UniswapV2Library.getAmountsIn(UniswapV2Factoryaddress, amountMTT, path)[0];//FUSD数量
           IV3SwapRouter.ExactInputSingleParams memory param = IV3SwapRouter.ExactInputSingleParams(MTTaddress, FUSDaddress, 3000, address(this), amount, 0, 0);
           amountReceived = uv3router.exactInputSingle(param);
           tokenBorrow = FUSDaddress;
        }
        require(amountReceived > amountShouldIN, "amountReceived <= amountShouldIN");
        IERC20(tokenBorrow).transfer(UV2Pairaddress, amountShouldIN); 
        IERC20(tokenBorrow).transfer(sender, amountReceived-amountShouldIN);
    }


    function testUV3(uint8 choose, uint256 amount) public returns(uint256){
        MTT.approve(address(this), uint(100000000000000000000000000));
        FUSD.approve(address(this), uint(100000000000000000000000000));
        MTT.approve(address(uv3router), uint(100000000000000000000000000));
        FUSD.approve(address(uv3router), uint(100000000000000000000000000));
        uint256 amountReceived;
        if(choose == 1){
           FUSD.transferFrom(msg.sender, address(this), amount);
           IV3SwapRouter.ExactInputSingleParams memory param = IV3SwapRouter.ExactInputSingleParams(FUSDaddress, MTTaddress, 3000, address(this), amount, 0, 0);
           amountReceived = uv3router.exactInputSingle(param);
        }else{
           MTT.transferFrom(msg.sender, address(this), amount);
           IV3SwapRouter.ExactInputSingleParams memory param = IV3SwapRouter.ExactInputSingleParams(MTTaddress, FUSDaddress, 3000, address(this), amount, 0, 0);
           amountReceived = uv3router.exactInputSingle(param);
        }
        console.log("amountReceived = ",amountReceived);
        return amountReceived;
    }

    address aaveKoven = 0x88757f2f99175387aB4C6a4b3067c77A695b0349;
    /*
    aave 
    • 调⽤ Pool 合约的 flashLoanSimple() 或 flashLoan()
    • Pool 合约将所借资产转到调⽤者指定的 receiver 合约地址
    • Pool 合约调⽤ receiver 合约的 executeOperation()
    • receiver 合约的 executeOperation() 执⾏⾃⼰的逻辑
    • receiver 合约的 executeOperation() 授权给Pool 合约所借⾦额+⼿续费
    • Pool 合约调⽤ safeTransferFrom() 从 receiver 转账过来 
    */
    function testAAVE(){
        
    }

}
