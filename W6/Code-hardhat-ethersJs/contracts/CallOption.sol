// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./MyCallOptionToken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


contract CallOption is ERC721, ERC721Enumerable, Ownable{
  using Counters for Counters.Counter;
  using SafeMath for uint;
  Counters.Counter private _tokenIds;

  address MyCallOptionTokenAddress;
  mapping(uint => string)public _tokenIdToOptionDescription;

  uint256 Min_Fill_Amount = 1; //最小单位
  mapping (uint256=>uint256)private tokenIdToPrice;//nftid - 期权单价
  mapping (uint256=>uint256)private tokenIdToTotalAmount;//nftid - 记录总期权数量
  mapping (uint256=>uint256)private tokenIdToStartTime;//nftid - 期权可以执行的起始期限
  mapping (uint256=>uint256)private tokenIdToEndTime;//nftid - 期权可以执行的最后期限
  
  constructor(address _myCallOptionTokenAddress) ERC721("One Ring Collection", "ORC") {
      MyCallOptionTokenAddress = _myCallOptionTokenAddress;
  }
  
  function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
    super._beforeTokenTransfer(from, to, tokenId);
  }

  function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
    return super.supportsInterface(interfaceId);
  }
 

  function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
     return super.tokenOfOwnerByIndex(owner, index);
  }
  /*
  1. 发行 (项目方)
  期权买入方按照一定的价格_price，在规定的期限[_startTime, _endTime]内享有向期权卖方购入某种商品或期货合约的权利
  * 铸造发行看涨期权NFT 指定价格 时间 数量 *

  @_description optionDescription
  @_price  WEI/MyCallOptionToken 设定价格为1Wei. eth should pay = _totalAmount
  @_totalAmount 1个最小单位MyCallOptionToken的价格为Price，计算总价为：_price.mul(_totalAmount)  MyCallOptionToken
  */
  function mintOptionNFTandOptionToken(string memory _description,uint256 _price, uint256 _totalAmount,uint256 _startTime, uint256 _endTime)payable public{ 
    require(SafeMath.mul(_price, _totalAmount) <= msg.value, "ETH not enough");  
    require(_startTime < _endTime,"_startTime < _endTime!");
    _tokenIds.increment();
    uint256 newItemId = _tokenIds.current();
    _safeMint(msg.sender, newItemId);//NFT给项目方
    _tokenIdToOptionDescription[newItemId] = _description;
    tokenIdToPrice[newItemId] = _price;
    tokenIdToTotalAmount[newItemId] = _totalAmount;
    tokenIdToStartTime[newItemId] = block.timestamp + 5;//5s后开始
    tokenIdToEndTime[newItemId] = block.timestamp + _endTime-_startTime;//_endTime-_startTimes后结束
    MyCallOptionToken(MyCallOptionTokenAddress).mint(address(this), _totalAmount);//发行的ERC20 MyCallOptionToken给合约地址
  }
  /*
  2. 购买 （用户）
  指定期权Id
  用户支付eth，自动计算期权对应的MyCallOptionToken的数量 WEI/WEI=amount
  合约收到eth，转MyCallOptionToken给用户
  */
  function buyOptionByETH(uint256 _optionId)payable public{
    require(_optionId <= _tokenIds.current(), "optionId does not exist !");
    
    uint256 price = tokenIdToPrice[_optionId];
    uint256 amountOfMyCallOptionToken = SafeMath.div(msg.value, price);
    require(amountOfMyCallOptionToken > 0, "amountOfMyCallOptionToken > 0");
    IERC20(MyCallOptionTokenAddress).approve(address(this),amountOfMyCallOptionToken);
    IERC20(MyCallOptionTokenAddress).transferFrom(address(this), msg.sender, amountOfMyCallOptionToken);

  }

  /*
  3. 行权 （用户）
  用户转入MyCallOptionToken
  合约按期权对应的价格支付eth
  */
  function fillOption(uint256 _optionId, uint256 _amount)public {
      require(_optionId <= _tokenIds.current(), "optionId does not exist!");
      require(_amount >= Min_Fill_Amount, "amount >= Min_Fill_Amount!");
      uint256 startTime = tokenIdToStartTime[_optionId];
      uint256 endTime = tokenIdToEndTime[_optionId];
      require(block.timestamp > startTime && block.timestamp < endTime, "block.timestamp > startTime && block.timestamp < endTime!");
      //先approve address(this)
      MyCallOptionToken(MyCallOptionTokenAddress).transferFrom(msg.sender, address(this), _amount);
      
      uint256 price = tokenIdToPrice[_optionId];
      uint256 weiAmountOfETH = SafeMath.mul(_amount, price);
      
      payable(msg.sender).transfer(weiAmountOfETH);
  }

  /*
  4. 销毁 (项目方)
  */
  function burnOption(uint256 _optionId)public{
      require(_optionId <= _tokenIds.current(), "optionId does not exist!");
      uint256 balanceOFMyCallOptionToken = MyCallOptionToken(MyCallOptionTokenAddress).balanceOf(address(this));
      IERC20(MyCallOptionTokenAddress).approve(address(this),balanceOFMyCallOptionToken);//批准ERC20
    //   MyCallOptionToken(MyCallOptionTokenAddress).approve(address(this),_optionId);//批准NFT
      MyCallOptionToken(MyCallOptionTokenAddress).transferFrom(address(this), address(1), balanceOFMyCallOptionToken);//销毁MyCallOptionToken
      CallOption(address(this)).transferFrom(msg.sender, address(1), _optionId);//销毁NFT
      payable(msg.sender).transfer(address(this).balance);//提eth
      tokenIdToPrice[_optionId] = 0;
      tokenIdToTotalAmount[_optionId] = 0;
      tokenIdToStartTime[_optionId] = 0;
      tokenIdToEndTime[_optionId] = 0;
  }
 
}