// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/swap-router-contracts/contracts/interfaces/IV3SwapRouter.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

//aave
import {SafeMath} from "@aave/core-v3/contracts/dependencies/openzeppelin/contracts/SafeMath.sol";
import {IFlashLoanSimpleReceiver} from "@aave/core-v3/contracts/flashloan/interfaces/IFlashLoanSimpleReceiver.sol";
import {IPoolAddressesProvider} from "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import {IPool} from "@aave/core-v3/contracts/interfaces/IPool.sol";

/*
aave testnet address
https://docs.aave.com/developers/deployed-contracts/v3-testnet-addresses
*/


contract AAVETest is IFlashLoanSimpleReceiver {
    using SafeMath for uint256;
    
   
    //uniswap v2 v3
    address UniswapV2Router02address = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address UniswapV2Factoryaddress = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address UNIV3POSaddress = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88;
    address UniswapV3Factoryaddress = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
    address SwapRouter02address = 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45;
    //my tokens
    address MTTaddress = 0xB9b56CE66C63DB98E6CDdacDF910C227294a8840;
    address AAVEaddress = 0x953af320e2bD3041c4e56BB3a30E7f613a1f3C1A;
    address DAIaddress = 0x2Ec4c6fCdBF5F9beECeB1b51848fc2DB1f3a26af;
    //addLiquidity https://kovan.etherscan.io/tx/0x3eb3b9d23eeec8c94775cb87197fa087feab5bbb854e913c362c3421898ccd59
    address UV2Pairaddress = 0x91337CcD2eDF1dF2D252f563B27341D52EEdbe78;//V2 pair
    //addLiquidity https://kovan.etherscan.io/tx/0x577836b44db5c729beb32fdc1ce27ebbc3e9347fa34959860ff2e258e4b2694a
    uint256 UV3tokenId = 10961;


/*
koven:
PoolAddressesProvider-Aave 0x651b8A8cA545b251a8f49B57D5838Da0a8DFbEF9 Pool-Proxy-Aave 0x329462f8ed05E5FfBF6dfB84106e76B69e6B1F94   
rinkeby:
PoolAddressesProvider-Aave  0xBA6378f1c1D046e9EB0F538560BA7558546edF3C Pool-Proxy-Aave 0xE039BdF1d874d27338e09B55CB09879Dedca52D8 
rinkeby2: 0xA55125A90d75a95EC00130E8E8C197dB5641Eb19 aave 0x953af320e2bD3041c4e56BB3a30E7f613a1f3C1A 
FTM testnet
PoolAddressesProvider-Fantom 0xE339D30cBa24C70dCCb82B234589E3C83249e658 Pool-Proxy-Fantom 0x771A45a19cE333a19356694C5fc80c76fe9bc741 
v2-v3:
LendingPool -> Pool
LendingPoolAddressesProvider -> PoolAddressesProvider
ProtocolDataProvider -> PoolDataProvider
*/

    address PoolAddressesProvider = 0xA55125A90d75a95EC00130E8E8C197dB5641Eb19;//


    
    //uniswap
    IUniswapV2Router02 uv2router = IUniswapV2Router02(UniswapV2Router02address);//exchange v2 
    IV3SwapRouter uv3router = IV3SwapRouter(SwapRouter02address);//exchange v3 multicall(uint256 deadline, bytes[] data)
    IERC20 MTT = IERC20(MTTaddress);
    IERC20 AAVE = IERC20(AAVEaddress);
    IERC20 DAI = IERC20(DAIaddress);


    //aave
    IPoolAddressesProvider public immutable override ADDRESSES_PROVIDER;
    IPool public immutable override POOL;

    constructor() {
        ADDRESSES_PROVIDER = IPoolAddressesProvider(PoolAddressesProvider);
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
    function testAAVE(address asset,uint256 _amount) public {
        address receiverAddress = address(this);

        address[] memory assets = new address[](1);
        assets[0] = asset;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = _amount;
        uint256[] memory interestRateModes = new uint256[](1);
        interestRateModes[0] = 0;//0 -> Don't open any debt, just revert if funds can't be transferred from the receiver


        bytes memory params = "";
        uint16 referralCode = 0;
        MTT.approve(address(uv2router), uint(100000000000000000000000000));
        MTT.approve(address(uv3router), uint(100000000000000000000000000));
        DAI.approve(address(uv2router), uint(100000000000000000000000000));
        DAI.approve(address(uv3router), uint(100000000000000000000000000));
    
        POOL.flashLoan(receiverAddress, assets, amounts, interestRateModes, receiverAddress, params,referralCode);
    }

    function testAAVESimple(address asset,uint256 amount) public {
        address receiver = address(this);
        bytes memory params = "";
        uint16 referralCode = 0;
        MTT.approve(address(uv2router), uint(100000000000000000000000000));
        MTT.approve(address(uv3router), uint(100000000000000000000000000));
        DAI.approve(address(uv2router), uint(100000000000000000000000000));
        DAI.approve(address(uv3router), uint(100000000000000000000000000));
        POOL.flashLoanSimple(receiver, asset, amount, params, referralCode);
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
        IERC20(asset).approve(address(POOL), amountOwing);
        address[] memory path = new address[](2);
        path[0] = DAIaddress;
        path[1] = MTTaddress;
        //v2：1 dai = 1000 MTT
        //v3: 1 dai = 100 MTT
        //amount 个 dai 在 v2 换 amountOut 个 MTT 
        //amountOut 个 MTT 在 v3 换 amountReceived 个 dai
        uint amountOut = IUniswapV2Router01(uv2router).swapExactTokensForTokens(amount, 1, path, address(this), block.timestamp)[1];
        IV3SwapRouter.ExactInputSingleParams memory param = IV3SwapRouter.ExactInputSingleParams(MTTaddress, DAIaddress, 3000, address(this), amountOut, 0, 0);
        uint amountReceived = uv3router.exactInputSingle(param);

        if(amountReceived > amountOwing){//成功才还钱
       //     IERC20(asset).approve(address(POOL), amountOwing);
        }else{
        //    IERC20(asset).approve(address(POOL), 0);
        }
        return true;
    }
    

}
