var VirtualWallet = artifacts.require("VirtualWallet");

contract("VirtualWallet payin and payout test", async (accounts) => {
    it("test payin", async () => {

        let testWallet = await VirtualWallet.deployed();
        let testValue = 1000;

        let before = await testWallet.getBalance(accounts[0]);
        assert.equal(before, 0, "Should be zero");

        await testWallet.payIn({from: accounts[0], value: testValue});

        let after = await testWallet.getBalance(accounts[0]);
        assert.equal(after, testValue, "Should be equal");

    })
})