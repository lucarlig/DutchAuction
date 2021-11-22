from brownie import DutchAuctionLot, accounts, chain

# more tests would be needed for production (eg. testing bounds, testing failure conditions)


def test_pot_get_price():
    account = accounts[0]
    startTime = chain.time() + 5 * 24 * 60 * 60
    endTime = chain.time() + 10 * 24 * 60 * 60
    dutch_auction = DutchAuctionLot.deploy(
        5_000_000_000,
        2_000_000_000,
        startTime,
        endTime,
        100,
        {"from": account},
    )

    chain.sleep(6 * 24 * 60 * 60)
    chain.mine()
    price = dutch_auction.getPrice(100)

    assert 5_000_000_000 > price and 0 < price


def test_pot_bid_full_lot():
    seller = accounts[0]
    buyer = accounts[1]
    init_buyer_balance = buyer.balance()
    init_seller_balance = seller.balance()
    requested_lot_size = 100
    startTime = chain.time() + 5 * 24 * 60 * 60
    endTime = chain.time() + 10 * 24 * 60 * 60
    dutch_auction = DutchAuctionLot.deploy(
        5_000_000_000,
        2_000_000_000,
        startTime,
        endTime,
        100,
        {"from": seller},
    )

    chain.sleep(6 * 24 * 60 * 60)
    chain.mine()
    payment = dutch_auction.getPrice(requested_lot_size)
    tx = dutch_auction.bid(requested_lot_size, {"from": buyer, "amount": payment})
    tx.wait(1)

    assert buyer.balance() == init_buyer_balance - payment
    assert seller.balance() == init_seller_balance + payment


def test_pot_bid_multiple_buyers():
    seller = accounts[0]
    buyers = [accounts[1], accounts[2], accounts[3]]
    init_balances = [
        accounts[1].balance(),
        accounts[2].balance(),
        accounts[3].balance(),
    ]
    requestLotSizes = [50, 23, 31]
    lotSize = 250
    init_seller_balance = seller.balance()
    startTime = chain.time() + 5 * 24 * 60 * 60
    endTime = chain.time() + 10 * 24 * 60 * 60
    dutch_auction = DutchAuctionLot.deploy(
        5_000_000_000,
        2_000_000_000,
        startTime,
        endTime,
        lotSize,
        {"from": seller},
    )
    chain.sleep(6 * 24 * 60 * 60)
    chain.mine()

    for i in range(3):
        chain.sleep(i * 24 * 60 * 60)
        chain.mine()
        payment = dutch_auction.getPrice(requestLotSizes[i])
        tx = dutch_auction.bid(
            requestLotSizes[i], {"from": buyers[i], "amount": payment}
        )
        tx.wait(1)
        assert buyers[i].balance() == init_balances[i] - payment
        assert seller.balance() == init_seller_balance + payment
        init_seller_balance = seller.balance()
