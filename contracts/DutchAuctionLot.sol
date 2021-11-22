pragma solidity ^0.8.0;

contract DutchAuctionLot {
    // start date, end date, start price, reserve price and total size of lot.
    uint256 public startDate;
    uint256 public endDate;
    uint256 public startPrice;
    uint256 public reservePrice;
    uint256 public lotSize;
    uint256 public availableLotSize;
    mapping(address => uint256) public reserved;
    address public seller;

    constructor(
        uint256 _startPrice,
        uint256 _reservePrice,
        uint256 _startDate,
        uint256 _endDate,
        uint256 _lotSize
    ) {
        require(
            _endDate > _startDate,
            "End date must be later than start date"
        );
        require(
            block.timestamp <= _startDate,
            "_startDate should be a date in the future"
        );

        startPrice = _startPrice;
        reservePrice = _reservePrice;
        startDate = _startDate;
        endDate = _endDate;
        lotSize = _lotSize;
        availableLotSize = _lotSize;
        seller = msg.sender;
    }

    function getPrice(uint256 _lotSize) public view returns (uint256) {
        require(block.timestamp < endDate, "Auction has expired");
        require(availableLotSize >= _lotSize, "lot size not available");
        if (block.timestamp < startDate) {
            return startPrice;
        }

        uint256 duration = endDate - startDate;
        uint256 priceStep = (startPrice - reservePrice) / duration;
        uint256 timeElapsed = block.timestamp - startDate;
        uint256 price = startPrice - (timeElapsed * priceStep);
        uint256 lotPrice = price / _lotSize;

        return lotPrice;
    }

    function bid(uint256 _requestedLotSize) public payable {
        require(
            block.timestamp < endDate && block.timestamp > startDate,
            "Auction is not active"
        );
        require(
            _requestedLotSize <= availableLotSize,
            "requested lot size bigger than available lot size"
        );

        uint256 price = getPrice(_requestedLotSize);
        require(msg.value >= price, "bid lower than current price");

        (bool sent, ) = seller.call{value: msg.value}("");
        require(sent, "Failed to send Ether to the seller");

        send_reward(msg.sender, _requestedLotSize);
        reserved[msg.sender] = _requestedLotSize;
        availableLotSize = availableLotSize - _requestedLotSize;
    }

    function send_reward(address _winner, uint256 _lotSize) internal {
        // send some sort of reward to the winner
    }
}
