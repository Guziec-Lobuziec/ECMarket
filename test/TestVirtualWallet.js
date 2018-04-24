var VirtualWallet = artifacts.require("VirtualWallet");

contract("VirtualWallet payin and payout test", async (accounts) => {
    it("test payin", async () => {

        let testWallet = await VirtualWallet.deployed();
        let testValue = 1000;

        assert.equal(await testWallet.getBalance(accounts[0]), 0, "Should be zero");

        await testWallet.payIn({from: accounts[0], value: testValue});

        assert.equal(await testWallet.getBalance(accounts[0]), testValue, "Should be equal");

    })
})