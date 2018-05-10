var VirtualWallet = artifacts.require("VirtualWallet");

contract("VirtualRating Tests", async (accounts) => {
    let testRank;
    
    before(async () => {
        testRank = await VirtualWallet.deployed();
    })

    it("test rank-presence", async () => {
        let testRating = 0;

        assert.equal(testRank.getRank(testRank.address), testRating, "Should be 0");
    })

})