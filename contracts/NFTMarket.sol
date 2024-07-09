// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "hardhat/console.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";

contract MyNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _tokensSold;
    
    address payable owner;
    uint256 ListingPrice = 0.0015 ether;

    mapping(uint256 => MarketItem) private idMarketItem;

    struct MarketItem {
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;

    }

    event idMarketItemCreated(
        uint256 indexed tokenid,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );
    modifier onlyOwner(){
        require(
            msg.sender ==owner,
            "only owner can call this function"

        );
        _;
    }

    constructor() ERC721("NFT Metavarse Token", "MYNFT"){
        owner == payable(msg.sender);

    }
    
    function updateListingPrice(uint256 _listingPrice)public payable onlyOwner(){
        ListingPrice = _listingPrice;
    }

    function getListingPrice() public view returns(uint256){
        return ListingPrice;
    }

    //nft token function
    function createToken(string memory tokenURI, uint256 price) public payable returns(uint256) {
       _tokenIds.increment();
        
        uint256 newTokenId = _tokenIds.current();

        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);

        createMarketItem(newTokenId, price);
        return newTokenId;

    }

    function createMarketItem(uint256 _tokenId, uint256 _price) private { 
        require(_price > 0, "Price must be  atleast 1");
        require(msg.value == ListingPrice);

        idMarketItem[_tokenId] = MarketItem(
            _tokenId,
            payable(msg.sender),
            payable(address(this)),
            _price,
            false
        );

        _transfer(msg.sender, address(this), _tokenId);
        emit idMarketItemCreated(_tokenId, msg.sender, address(this), _price, false);

    }

    //SALE NFT TOKEN
    function sellToken(uint256 _tokenId, uint256 price) public payable {
        require(idMarketItem[_tokenId].owner == msg.sender, "only owner of nft can call this function");
        require(msg.value == ListingPrice, "must be equal to listing price");
        //reset the properties
        idMarketItem[_tokenId].sold = false;
        idMarketItem[_tokenId].price = price;
        idMarketItem[_tokenId].seller = payable(msg.sender);
        idMarketItem[_tokenId].owner = payable(address(this));

        _tokensSold.decrement();
        _transfer(msg.sender, address(this), _tokenId);

    }

    function CreateMarketSale(uint256 _tokenId) public payable {
        uint256 price = idMarketItem[_tokenId].price;
        require(msg.value == price, "not the asking price");

        idMarketItem[_tokenId].owner = payable(msg.sender);
        idMarketItem[_tokenId].sold = true;
        idMarketItem[_tokenId].owner = payable(address(0));
        
        _transfer(address(this), msg.sender, _tokenId);

        payable(owner).transfer(ListingPrice);
        payable(idMarketItem[_tokenId].seller).transfer(msg.value);
    }
    function fetchMarketItem() public view returns (MarketItem[] memory) {
        uint256 itemCount = _tokenIds.current();
        uint256 unSoldItemsCount = itemCount - _tokensSold.current();
        uint256 currentid = 0;

        MarketItem[] memory items = new MarketItem[](unSoldItemsCount);
        for (uint256 i = 0; i < itemCount; i++) {
            if (idMarketItem[i +1].owner == address(this)) {
                uint256 currentId = i +1;
                MarketItem storage currentItem = idMarketItem[currentId];
            }
        }


    }


}
