var VirtualWallet = artifacts.require("VirtualWallet");

contract("VirtualRating Tests", async (accounts) => {
    let testRank;
    
    before(async () => {
        testRank = await VirtualWallet.deployed();
    })

    it("test rank-presence", async () => {
        let testRating = 0;

        assert.equal(testRank.getRank.call(accounts[0]), testRating, "Should be 0");
    })

})