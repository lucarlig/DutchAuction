from brownie import DutchAuction, accounts, chain

# more tests would be needed for production (eg. testing bounds, testing failure conditions)


def test_WTIA_get_price():
    account = accounts[0]
    startTime = chain.time() + 5 * 24 * 60 * 60
    endTime = chain.time() + 10 * 24 * 60 * 60
    dutch_auction = DutchAuction.deploy(
        5_000_000_000,
        startTime,
        endTime,
        {"from": account},
    )
    chain.sleep(6 * 24 * 60 * 60)
    chain.mine()
    price = dutch_auction.getPrice()
    assert 5_000_000_000 > price and 0 < price


def test_WTIA_bid():
    seller = accounts[0]
    buyer = accounts[1]
    init_buyer_balance = buyer.balance()
    init_seller_balance = seller.balance()
    startTime = chain.time() + 5 * 24 * 60 * 60
    endTime = chain.time() + 10 * 24 * 60 * 60
    dutch_auction = DutchAuction.deploy(
        5_000_000_000,
        startTime,
        endTime,
        {"from": seller},
    )
    chain.sleep(9 * 24 * 60 * 60)
    chain.mine()
    payment = dutch_auction.getPrice()
    tx = dutch_auction.bid({"from": buyer, "amount": payment})
    tx.wait(1)
    assert buyer.balance() == init_buyer_balance - payment
    assert seller.balance() == init_seller_balance + payment


def test_WTIA_bid_perfect_timing():
    seller = accounts[0]
    buyer = accounts[1]
    init_buyer_balance = buyer.balance()
    init_seller_balance = seller.balance()
    startTime = chain.time() + 5 * 24 * 60 * 60
    endTime = chain.time() + 10 * 24 * 60 * 60
    dutch_auction = DutchAuction.deploy(
        5_000_000_000,
        startTime,
        endTime,
        {"from": seller},
    )
    chain.sleep(10 * 24 * 60 * 60 - 100)
    chain.mine()
    payment = dutch_auction.getPrice()
    tx = dutch_auction.bid({"from": buyer, "amount": payment})
    tx.wait(1)
    assert buyer.balance() == init_buyer_balance - payment
    assert seller.balance() == init_seller_balance + payment
