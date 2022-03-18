
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: Code-hardhat-ethersJs/contracts/IMasterChef.sol


pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;


interface IMasterChef {
    
    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
    }

    struct PoolInfo {
        IERC20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. SUSHI to distribute per block.
        uint256 lastRewardBlock;  // Last block number that SUSHI distribution occurs.
        uint256 accSushiPerShare; // Accumulated SUSHI per share, times 1e12. See below.
    }

    function userInfo(uint256 _pid,address user) external view returns (IMasterChef.UserInfo memory);
    function poolInfo(uint256 pid) external view returns (IMasterChef.PoolInfo memory);
    function totalAllocPoint() external view returns (uint256);
    function deposit(uint256 _pid, uint256 _amount) external;
    function withdraw(uint256 _pid, uint256 _amount) external;
}
// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol

pragma solidity >=0.6.2;


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// File: Code-hardhat-ethersJs/contracts/MyTokenMarket.sol



pragma solidity ^0.8.0;




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
