// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract OneRingNFT is ERC721 {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;
  string[] public tokenURIs;
  mapping(string => bool)public _tokenURIExists;
  mapping(uint => string)public _tokenIdToTokenURI;
  

  
  constructor() ERC721("One Ring Collection", "ORC") {}

  function tokenURI(uint256 tokenId) public override view returns (string memory) {
    require(_exists(tokenId), 'ERC721Metadata: URI query for nonexistent token');
    return _tokenIdToTokenURI[tokenId];
  }


  function safeMint(string memory _tokenURI) public {
    require(!_tokenURIExists[_tokenURI], 'The token URI should be unique');
    tokenURIs.push(_tokenURI);    
    _tokenIds.increment();
    uint256 newItemId = _tokenIds.current();
    _tokenIdToTokenURI[newItemId] = _tokenURI;
    _safeMint(msg.sender, newItemId);
    _tokenURIExists[_tokenURI] = true;
  }

}