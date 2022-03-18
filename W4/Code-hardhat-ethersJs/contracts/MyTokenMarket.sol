// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "./IMasterChef.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//0x25323EC01224c2e58Ba0988b674830C77E098EBe
contract MyTokenMarket{
   //UniswapV2Router02
   /*
   Sushi
   https://ropsten.etherscan.io/address/0xf42a08c0ea66ee4a474336087a6c17e9ea6c9de9
   MasterChef
   https://ropsten.etherscan.io/address/0xd9dfa8c6b37cfdf16668fe0465896f4a1b9b2c4f
   */
    address uv2address = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address wethaddress = 0xc778417E063141139Fce010982780140Aa0cD5Ab;
    address mytokenaddress = 0xBD6efD9aC4bD6082d0DCf02AF2eCB28f07017375;
    address sushiaddress = 0xf42A08C0EA66ee4A474336087A6C17E9EA6c9dE9;
    address masterchefaddress = 0xd9DFA8c6b37cfDF16668fE0465896f4A1B9b2c4F;
    IUniswapV2Router02 uv2router = IUniswapV2Router02(uv2address);
    IERC20 mtoken = IERC20(mytokenaddress);
    IMasterChef masterChef = IMasterChef(masterchefaddress);
    constructor(){
    }

/*
先直接调用UniswapV2Router（0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D）addLiquidityETH 创建出Uniswap V2 pair（0x3a8084802a32fb9c6eee81cca61d7895a513d2b2）
addLiquidity 调用mytoken                授权MyTokenMarket使用User      授权UniswapV2Router使用MyTokenMarket 
depositToMasterChef调用Uniswap V2 pair  授权MyTokenMarket使用User   授权MasterChef使用MyTokenMarket
depositToMasterChef调用MasterChef（0xd9dfa8c6b37cfdf16668fe0465896f4a1b9b2c4f） add(_allocPoint,_lpToken,_withUpdate)创建poolInfo ,其中_lpToken为Uniswap V2 pair
*/
    function addLiquidity(
        uint amountMyTokenDesired
    ) external payable returns(uint256 amountOfLp){
        //本合约授权给uv2router
        mtoken.approve(address(uv2router), amountMyTokenDesired);
        bool success = mtoken.transferFrom(msg.sender, address(this), amountMyTokenDesired);
        require(success, "mtoken transfer error!");
        (uint amountToken,,) = uv2router.addLiquidityETH{value: msg.value}( mytokenaddress, amountMyTokenDesired, 0, 0, msg.sender,block.timestamp);
        return amountToken;
    }
    /*
    pid = 1
    [ poolInfo(uint256) method Response ]
    lpToken   address :  0xbAa1A3FEeA96A6c7034B496E617F80C88beE3743
    allocPoint   uint256 :  100
    lastRewardBlock   uint256 :  12101537
    accSushiPerShare   uint256 :  0
    */
    function depositToMasterChef(address lpAddress,uint256 pid, uint256 amount)public{
        IERC20(lpAddress).approve(masterchefaddress, amount);
        IERC20(lpAddress).transferFrom(msg.sender, address(this), amount);
        masterChef.deposit(pid,amount);
    }


    function buyExactTokenByETH(uint amountOutMin)public payable{
            address[] memory path = new address[](2);
            path[0] = address(wethaddress);
            path[1] = address(mytokenaddress);
            uv2router.swapExactETHForTokens{value: msg.value}(amountOutMin, path, msg.sender, block.timestamp);
    }


    function withdraw(uint256 pid)public{
        IMasterChef.UserInfo memory userInfo = masterChef.userInfo(pid, address(this));
        IMasterChef.PoolInfo memory poolInfo = masterChef.poolInfo(pid);
        masterChef.withdraw(pid,userInfo.amount);
        IERC20(poolInfo.lpToken).approve(address(this),userInfo.amount);
        IERC20(poolInfo.lpToken).transferFrom(address(this), msg.sender,userInfo.amount);
    }


}
