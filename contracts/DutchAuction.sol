//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract DutchAuction {
    uint256 public initialPrice;
    uint256 public startDate;
    uint256 public endDate;
    address public seller;
    address public winner;

    constructor(
        uint256 _initialPrice,
        uint256 _startDate,
        uint256 _endDate
    ) {
        require(
            _endDate > _startDate,
            "End date must be later than start date"
        );
        require(
            block.timestamp <= _startDate,
            "_startDate should be a date in the future"
        );

        initialPrice = _initialPrice;
        startDate = _startDate;
        endDate = _endDate;
        seller = msg.sender;
    }

    function getPrice() public view returns (uint256) {
        require(block.timestamp < endDate, "Auction has expired");
        if (block.timestamp < startDate) {
            return initialPrice;
        }

        uint256 duration = endDate - startDate;
        uint256 priceStep = initialPrice / duration;
        uint256 timeElapsed = block.timestamp - startDate;
        uint256 price = initialPrice - (timeElapsed * priceStep);
        return price;
    }

    function bid() public payable {
        require(
            block.timestamp < endDate && block.timestamp > startDate,
            "Auction is not active"
        );

        uint256 price = getPrice();
        require(msg.value >= price, "bid lower than current price");

        (bool sent, ) = seller.call{value: msg.value}("");
        require(sent, "Failed to send Ether to the seller");

        winner = msg.sender;
        send_reward(winner);
    }

    function send_reward(address _winner) internal {
        // send some sort of reward to the winner
    }
}
