// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
contract NFTMarket is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;
    address payable owner;
    uint256 listingPrice= 0.025 ether;

    constructor() {
        owner = payable(msg.sender);
    }
    struct MarketItems {
        uint itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
        
    }
    mapping (uint256 => MarketItems) private idToMarketItem;
   event ItemCreated(
    uint indexed itemId,
    address indexed nftContract,
    uint256 indexed tokenId,
    address seller,
    address owner,
    uint256 price,
    bool sold

   );
   function createItem(address nftContract,uint256 tokenId,uint256 price) public payable nonReentrant{
    require(price>0,"price must be greater than 0!");
    require(msg.value==listingPrice,"Price must be equal to listing price");
    _itemIds.increment();
    uint256 itemId= _itemIds.current();
    idToMarketItem[itemId]=MarketItems(
        itemId,
        nftContract,
        tokenId,
        payable(msg.sender),
        payable(address(0)),
        price,
        false
    );
    IERC721(nftContract).transferFrom(msg.sender,address(this),tokenId);
      emit ItemCreated(
        itemId,
        nftContract,
        tokenId,
        payable(msg.sender),
        payable(address(0)),
        price,
        false
      );

   }
   function createSale(address nftContract,uint256 itemId) public payable nonReentrant {
    uint price=idToMarketItem[itemId].price;
    uint tokenId=idToMarketItem[itemId].tokenId;
    require(msg.value==price,"pay full amount idiot!!");
    idToMarketItem[itemId].seller.transfer(msg.value);
    IERC721(nftContract).transferFrom(address(this),msg.sender,tokenId);
    idToMarketItem[itemId].owner=payable(msg.sender);
    idToMarketItem[itemId].sold=true;
    _itemsSold.increment();
    payable(owner).transfer(listingPrice);
   }
   function getListingPrice() public view returns (uint256) {
    return listingPrice;
   }
   function fetchMarketItems() public view returns(MarketItems[] memory){
    uint itemCount=_itemIds.current();
    uint unsoldItems=_itemIds.current()-_itemsSold.current();
    uint currentIndex=0;
    MarketItems[] memory items=new MarketItems[](unsoldItems);
    for(uint i=0;i<itemCount;i++){
        if(idToMarketItem[i+1].owner==address(0)){
            uint currentId=idToMarketItem[i+1].itemId;
            MarketItems storage currenItem=idToMarketItem[currentId];
            items[currentIndex]=currenItem;
            currentIndex+=1;
        }

    }
    return items;
   }

    function fetchMyNfts()public view returns (MarketItems[] memory){
        uint totalItem=_itemIds.current();
        uint itemCount=0;
        uint currentIndex=0;
        for(uint i=0;i<totalItem;i++){
            if(idToMarketItem[i+1].owner==msg.sender){
                itemCount+=1;
            }
        }
            MarketItems[] memory items=new MarketItems[](itemCount);
            for(uint i=0;i<totalItem;i++){
        if(idToMarketItem[i+1].owner==msg.sender){
            uint currentId=idToMarketItem[i+1].itemId;
            MarketItems storage currenItem=idToMarketItem[currentId];
            items[currentIndex]=currenItem;
            currentIndex+=1;
        }

    }
    return items;
    }
    function fetchItemsCreated()public view  returns (MarketItems[] memory) {
        uint totalItem=_itemIds.current();
        uint itemCount=0;
        uint currentIndex=0;
        for(uint i=0;i<totalItem;i++){
            if(idToMarketItem[i+1].seller==msg.sender){
                itemCount+=1;
            }
        }
            MarketItems[] memory items=new MarketItems[](itemCount);
        for(uint i=0;i<totalItem;i++){
        if(idToMarketItem[i+1].seller==msg.sender){
            uint currentId=idToMarketItem[i+1].itemId;
            MarketItems storage currenItem=idToMarketItem[currentId];
            items[currentIndex]=currenItem;
            currentIndex+=1;
        }

    }
    return items;   

        
    }
}