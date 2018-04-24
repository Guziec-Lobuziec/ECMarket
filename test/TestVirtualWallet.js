var VirtualWallet = artifacts.require("VirtualWallet");

contract("VirtualWallet payin and payout test", async (accounts) => {
    it("test payin", async () => {

        let testWallet = await VirtualWallet.deployed();
        let testValue = 1000;

        let before = await testWallet.getBalance(accounts[0]);
        assert.equal(before.toNumber(), "0", "Should be zero");

        await testWallet.payIn({from: accounts[0], value: testValue});

        let after = await testWallet.getBalance(accounts[0]);
        assert.equal(after.toNumber(), testValue, "Should be equal");

    })
    it("test payout", async () => {
        let testWallet = await VirtualWallet.deployed();
        let testValue = 500;

        let before = await testWallet.getBalance(accounts[0]);
        assert.equal(before.toNumber(),1000, "Should be 1000");


        await testWallet.payOut(testValue,{from: accounts[0]});
        let after = await testWallet.getBalance(accounts[0]);

        assert.equal(after.toNumber(),testValue, "Should be 500");
        let actualWalletBalance = await web3.eth.getBalance(testWallet.address);
        assert.equal(
            actualWalletBalance.toNumber(),
            testValue,
            "Contract balance should be equal to 500"
        );
    })
})