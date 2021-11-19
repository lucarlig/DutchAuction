//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract DutchAuction {

    uint256 initialPrice;
    uint256 reservePrice;
    uint256 startDate;
    uint256 endDate;
    address seller;
    address winner;
    bool active;

    function getPrice() public view returns (uint256) {
        require(isActive(), "Auction is not active");
        uint256 duration = endDate - startDate;
        uint256 priceDifference = initialPrice - reservePrice;
        uint256 priceStep = priceDifference / duration;
        uint256 timeElapsed = now - endDate;
        uint256 price = initialPrice - (priceDifference*priceStep);
        return price;
    }

    function bid(uint256 _bid) public payable {
        require(isActive(), "Auction is not active");
        uint256 price = getPrice();
        require(msg.value >= price, "bid lower than current price");
        (bool sent,) = seller.call{value: msg.value}("");
        require(sent, "Failed to send Ether to the seller");
        winner = msg.sender;
        stopAuction();
    }


    // do checking that start is smaller than end date and reserver price is lower than initial
    function initAuction(uint256 _initialPrice, uint256 _reservePrice, uint256 _startDate, uint256 _endDate) {

    }

    function stopAuction() {

    }

    function isActive() internal() {
        return now < endDate && active;
    }
    
}