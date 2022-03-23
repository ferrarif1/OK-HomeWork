// SPDX-License-Identifier: MIT

pragma solidity =0.6.0;

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Callee.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol";

import "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import "@uniswap/swap-router-contracts/contracts/interfaces/ISwapRouter02.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/*
V2: 1 MTT = 1 FUSD
V3: 1 MTT = 0.5 FUSD
*/

contract UV2FlashSwap is IUniswapV2Callee {
    address UniswapV2Router02address = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address UniswapV2Factoryaddress = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address UNIV3POSaddress = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88;
    address UniswapV3Factoryaddress = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
    address SwapRouter02address = 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45;
   
    address MTTaddress = 0x1862af5148ba4B8F48d9c512865DeC136025dC25;
    address FUSDaddress = 0xE91Df3FB3a027b32432AD91a93a6a0118486AF61;
    address UV2Pairaddress = 0x69AAbcC32124Ff3d3aCe6d6CD1808e33EC4F9b37;
    uint256 UV3tokenId = 16562;
    

    IUniswapV2Router02 uv2router = IUniswapV2Router02(UniswapV2Router02address);//exchange v2 
    IUniswapV2Factory uv2factory = IUniswapV2Factory(UniswapV2Factoryaddress);
    INonfungiblePositionManager uv3posmanager = INonfungiblePositionManager(UNIV3POSaddress);
    ISwapRouter02 uv3router = ISwapRouter02(SwapRouter02address);//exchange v3 multicall(uint256 deadline, bytes[] data) deadline：1648969613
    IERC20 MTT = IERC20(MTTaddress);
    IERC20 FUSD = IERC20(FUSDaddress);
    


    constructor() public {
    }


    // gets tokens/WETH via a V2 flash swap, swaps for the ETH/tokens on V1, repays V2, and keeps the rest!
    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external override {
        address[] memory path = new address[](2);
        path[0] = address(MTTaddress);
        path[1] = address(FUSDaddress);





        { // scope for token{0,1}, avoids stack too deep errors
        address token0 = IUniswapV2Pair(msg.sender).token0();
        address token1 = IUniswapV2Pair(msg.sender).token1();
        assert(msg.sender == UniswapV2Library.pairFor(factory, token0, token1)); // ensure that msg.sender is actually a V2 pair
        assert(amount0 == 0 || amount1 == 0); // this strategy is unidirectional
        path[0] = amount0 == 0 ? token0 : token1;
        path[1] = amount0 == 0 ? token1 : token0;
        amountToken = token0 == address(WETH) ? amount1 : amount0;
        amountETH = token0 == address(WETH) ? amount0 : amount1;
        }

        assert(path[0] == address(WETH) || path[1] == address(WETH)); // this strategy only works with a V2 WETH pair
        IERC20 token = IERC20(path[0] == address(WETH) ? path[1] : path[0]);
        IUniswapV1Exchange exchangeV1 = IUniswapV1Exchange(factoryV1.getExchange(address(token))); // get V1 exchange

        if (amountToken > 0) {
            (uint minETH) = abi.decode(data, (uint)); // slippage parameter for V1, passed in by caller
            token.approve(address(exchangeV1), amountToken);
            uint amountReceived = exchangeV1.tokenToEthSwapInput(amountToken, minETH, uint(-1));
            uint amountRequired = UniswapV2Library.getAmountsIn(factory, amountToken, path)[0];
            assert(amountReceived > amountRequired); // fail if we didn't get enough ETH back to repay our flash loan
            WETH.deposit{value: amountRequired}();
            assert(WETH.transfer(msg.sender, amountRequired)); // return WETH to V2 pair
            (bool success,) = sender.call{value: amountReceived - amountRequired}(new bytes(0)); // keep the rest! (ETH)
            assert(success);
        } else {
            (uint minTokens) = abi.decode(data, (uint)); // slippage parameter for V1, passed in by caller
            WETH.withdraw(amountETH);
            uint amountReceived = exchangeV1.ethToTokenSwapInput{value: amountETH}(minTokens, uint(-1));
            uint amountRequired = UniswapV2Library.getAmountsIn(factory, amountETH, path)[0];
            assert(amountReceived > amountRequired); // fail if we didn't get enough tokens back to repay our flash loan
            assert(token.transfer(msg.sender, amountRequired)); // return tokens to V2 pair
            assert(token.transfer(sender, amountReceived - amountRequired)); // keep the rest! (tokens)
        }
    }
}
