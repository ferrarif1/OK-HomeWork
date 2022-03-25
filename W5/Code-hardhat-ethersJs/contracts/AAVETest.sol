// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/swap-router-contracts/contracts/interfaces/IV3SwapRouter.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

//aave
import {IFlashLoanSimpleReceiver} from "@aave/core-v3/contracts/flashloan/interfaces/IFlashLoanSimpleReceiver.sol";
import {IPoolAddressesProvider} from "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import {IPool} from "@aave/core-v3/contracts/interfaces/IPool.sol";

/*
V2: 1 MTT = 1 FUSD
V3: 1 MTT = 0.5 FUSD
*/


contract AAVETest is IFlashLoanSimpleReceiver {
    //uniswap v2 v3
    address UniswapV2Router02address = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address UniswapV2Factoryaddress = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address UNIV3POSaddress = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88;
    address UniswapV3Factoryaddress = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
    address SwapRouter02address = 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45;
    //my tokens
    address MTTaddress = 0x8Ca302E2B04ECDb5d14Cced580A379b40e8eD8b7;
    address Linkaddress = 0xa36085F69e2889c224210F603D836748e7dC0088;
    //addLiquidity https://kovan.etherscan.io/tx/0x3eb3b9d23eeec8c94775cb87197fa087feab5bbb854e913c362c3421898ccd59
    address UV2Pairaddress = 0x69F9e353F7411479912d2E9F3e436aE83486C17B;//V2 pair
    //addLiquidity https://kovan.etherscan.io/tx/0x577836b44db5c729beb32fdc1ce27ebbc3e9347fa34959860ff2e258e4b2694a
    uint256 UV3tokenId = 10961;

   //aave
    address AAVE_ATOKEN_WETH = 0x87b1f4cf9BD63f7BBD3eE1aD04E8F52540349347;
    address AAVE_LENDING_POOL_ADDRESSES_PROVIDER = 0x88757f2f99175387aB4C6a4b3067c77A695b0349;
    address POOL = 0xE0fBa4Fc209b4948668006B2bE61711b7f465bAe;


    IPool public immutable override POOL;
    //uniswap
    IUniswapV2Router02 uv2router = IUniswapV2Router02(UniswapV2Router02address);//exchange v2 
    IV3SwapRouter uv3router = IV3SwapRouter(SwapRouter02address);//exchange v3 multicall(uint256 deadline, bytes[] data) deadline：1648969613
    IERC20 MTT = IERC20(MTTaddress);
    IERC20 FUSD = IERC20(FUSDaddress);

    //aave
    IPoolAddressesProvider public immutable override  ADDRESSES_PROVIDER = IPoolAddressesProvider(AAVE_LENDING_POOL_ADDRESSES_PROVIDER);

    constructor() {
        POOL = IPool(ADDRESSES_PROVIDER.getPool());
    }

/*          AAVE             */
    /*
    aave 
    • 调⽤ Pool 合约的 flashLoanSimple() 或 flashLoan()
    • Pool 合约将所借资产转到调⽤者指定的 receiver 合约地址
    • Pool 合约调⽤ receiver 合约的 executeOperation()
    • receiver 合约的 executeOperation() 执⾏⾃⼰的逻辑
    • receiver 合约的 executeOperation() 授权给Pool 合约所借⾦额+⼿续费
    • Pool 合约调⽤ safeTransferFrom() 从 receiver 转账过来 
    */
    function testAAVE(uint256 _amount) public {
        address receiverAddress = address(this);

        address asset = Linkaddress;
        uint256 amount = _amount;

        bytes memory params = "";
        uint16 referralCode = 0;

        POOL.flashLoanSimple(receiverAddress, asset, amount, params, referralCode);
    }

    function executeOperation(
        address asset,
        uint256 amount,//借来的数量
        uint256 premium,//利息
        address initiator,//发起人
        bytes calldata params
    ) external override returns (bool) {

        // Approve the LendingPool contract allowance to *pull* the owed amount
        //amount 需要还的link数量
        uint256 amountOwing = amount.add(premium);
        

        MTT.approve(address(uv2router), uint(100000000000000000000000000));
        MTT.approve(address(uv3router), uint(100000000000000000000000000));
      
        bytes memory data = bytes(0);

        address[] memory path = new address[](2);
        path[0] = Linkaddress;
        path[1] = MTTaddress;
        //v2：1 link = 1000 MTT
        //v3: 1 link = 100 MTT
        //amount 个 link 在 v2 换 amountOut 个 MTT 
        //amountOut 个 MTT 在 v3 换 amountReceived 个 link
        uint amountOut = uv2router.swapExactTokensForTokens(amount, 1, path, address(this), block.timestamp)[0];
        IV3SwapRouter.ExactInputSingleParams memory param = IV3SwapRouter.ExactInputSingleParams(MTTaddress, Linkaddress, 3000, address(this), amountOut, 0, 0);
        amountReceived = uv3router.exactInputSingle(param);

        if(amountReceived > amountOwing){//成功才还钱
            IERC20(asset).approve(address(POOL), amountOwing);
        }else{
            IERC20(asset).approve(address(POOL), 0);
        }
        return true;
    }
    

}
