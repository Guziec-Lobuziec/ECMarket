const {assertRevert} = require('./helpers/assertThrow');
const VirtualWallet = artifacts.require("VirtualWallet");

contract("VirtualWallet payin and payout test", async (accounts) => {
    let testWallet;

    before(async () => {
      testWallet = await VirtualWallet.deployed();
    })

    it("test payin", async () => {
        let testValue = 1000;

        let before = await testWallet.getBalance.call(accounts[0]);
        assert.equal(before.toNumber(), "0", "Should be zero");

        await testWallet.payIn({from: accounts[0], value: testValue});

        let after = await testWallet.getBalance.call(accounts[0]);
        assert.equal(after.toNumber(), testValue, "Should be equal");

    })
    it("test payout", async () => {
        let testValue = 500;

        let before = await testWallet.getBalance.call(accounts[0]);
        assert.equal(before.toNumber(),1000, "Should be 1000");


        await testWallet.payOut(testValue,{from: accounts[0]});
        let after = await testWallet.getBalance.call(accounts[0]);

        assert.equal(after.toNumber(),testValue, "Should be 500");
        let actualWalletBalance = await web3.eth.getBalance(testWallet.address);
        assert.equal(
            actualWalletBalance.toNumber(),
            testValue,
            "Contract balance should be equal to 500"
        );
    })
})

contract("VirtualWallet multiple users test", async (accounts) => {
  let testWallet;

  before(async () => {
    testWallet = await VirtualWallet.deployed();
  })

    it("multiple payins", async () => {
        let testValue1 = 2000;
        let testValue2 = 2000;

        let before1 = await testWallet.getBalance.call(accounts[0]);
        assert.equal(before1.toNumber(),0, "Should be 0");

        let before2 = await testWallet.getBalance.call(accounts[1]);
        assert.equal(before2.toNumber(),0, "Should be 0");

        await testWallet.payIn({from: accounts[0], value: testValue1});
        await testWallet.payIn({from: accounts[1], value: testValue2});

        let after1 = await testWallet.getBalance.call(accounts[0]);
        assert.equal(after1.toNumber(),testValue1, "Should be "+testValue1);

        let after2 = await testWallet.getBalance.call(accounts[1]);
        assert.equal(after2.toNumber(),testValue2, "Should be "+testValue2);

    })

    it("multiple payouts", async () => {
        let testValue1 = 2000;
        let testValue2 = 2000;
        let payout1 = 400;
        let payout2 = 1200;

        let before1 = await testWallet.getBalance.call(accounts[0]);
        assert.equal(before1.toNumber(),testValue1, "Should be "+testValue1);

        let before2 = await testWallet.getBalance.call(accounts[1]);
        assert.equal(before2.toNumber(),testValue2, "Should be "+testValue2);

        await testWallet.payOut(payout2,{from: accounts[1]});
        await testWallet.payOut(payout1,{from: accounts[0]});

        let after1 = await testWallet.getBalance.call(accounts[0]);
        assert.equal(
            after1.toNumber(),
            testValue1-payout1,
            "Should be "+(testValue1-payout1)
        );

        let after2 = await testWallet.getBalance.call(accounts[1]);
        assert.equal(
            after2.toNumber(),
            testValue2-payout2,
            "Should be "+(testValue2-payout2)
        );
    })
})

contract("VirtualWallet with invalid input", async (accounts) => {

  let testWallet;

  before(async () => {
    testWallet = await VirtualWallet.deployed();
  })

  it("throw if trying withdraw more than curently in wallet", async () => {
    let valueIn = 1000;
    let valueOut = 2000;

    await testWallet.payIn({from: accounts[0], value: valueIn});

    await assertRevert(testWallet.payOut(valueOut,{from: accounts[0]}));
  })
})
