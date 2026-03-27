// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AgentMarketplace {
    struct Listing {
        uint256 id;
        address payable seller;
        uint256 price;
        bool sold;
    }

    struct Offer {
        uint256 listingId;
        address buyer;
        uint256 offerPrice;
        bool accepted;
    }

    mapping(uint256 => Listing) public listings;
    mapping(uint256 => Offer[]) public offers;
    uint256 public listingCount;

    event ListingCreated(uint256 id, address seller, uint256 price);
    event OfferMade(uint256 listingId, address buyer, uint256 offerPrice);
    event OfferAccepted(uint256 listingId, address buyer);
    event ListingSold(uint256 id, address seller, address buyer);

    function createListing(uint256 price) external {
        require(price > 0, "Price must be greater than zero.");
        listingCount++;  
        listings[listingCount] = Listing(listingCount, payable(msg.sender), price, false);
        emit ListingCreated(listingCount, msg.sender, price);
    }

    function makeOffer(uint256 listingId, uint256 offerPrice) external {
        require(listings[listingId].id != 0, "Listing does not exist.");
        require(offerPrice > 0, "Offer price must be greater than zero.");
        require(!listings[listingId].sold, "Listing already sold.");

        offers[listingId].push(Offer(listingId, msg.sender, offerPrice, false));
        emit OfferMade(listingId, msg.sender, offerPrice);
    }

    function acceptOffer(uint256 listingId, uint256 offerIndex) external {
        Listing storage listing = listings[listingId];
        require(listing.seller == msg.sender, "Only seller can accept an offer.");
        require(!listing.sold, "Listing already sold.");
        Offer storage offer = offers[listingId][offerIndex];
        require(!offer.accepted, "Offer already accepted.");

        offer.accepted = true;
        listing.sold = true;
        listing.seller.transfer(offer.offerPrice);

        emit OfferAccepted(listingId, offer.buyer);
        emit ListingSold(listingId, listing.seller, offer.buyer);
    }

    function getListing(uint256 listingId) external view returns (Listing memory) {
        return listings[listingId];
    }

    function getOffers(uint256 listingId) external view returns (Offer[] memory) {
        return offers[listingId];
    }
}