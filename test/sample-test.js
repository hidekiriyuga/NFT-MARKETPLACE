const { expect } = require("chai");
describe("NFTMarket",function() {
    it("Should create and execute sales",async function(){
        const Market = await ethers.getContractFactory("NFTMarket")
        const market=await Market.deploy()
        await market.deployed()
        const marketaddress=market.address
        const NFT=await ethers.getContractFactory("NFT");
        const nft=await NFT.deploy(marketaddress)
        await nft.deployed
        const nftContractaddress=nft.address
        let listingprice=await market.getListingPrice()
        listingprice=listingprice.toString()
        const auctionPrice=ethers.utils.parseUnits('1','ether')
        await nft.createToken("https://www.mytokenlocation.com")
        await nft.createToken("https://www.mytokenlocation2.com")
        await market.createItem(nftContractaddress,1,auctionPrice,{value: listingprice})
        await market.createItem(nftContractaddress,2,auctionPrice,{value: listingprice})
        const [_,buyerAddress]=await ethers.getSigners()
        await market.connect(buyerAddress).createSale(nftContractaddress,1,{value: auctionPrice})
        let items=await market.fetchMarketItems()
        items = await Promise.all(items.map(async i =>{
            const tokenUri=await nft.tokenURI(i.tokenId)
            let item={
                price : i.price.toString(),
                tokenId: i.tokenId.toString(),
                seller: i.seller,
                owner: i.owner,
                tokenUri
            }
            return item
        }))
        console.log('item: ',items);

    });
});