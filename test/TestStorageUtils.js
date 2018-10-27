const {assertRevert} = require('./helpers/assertThrow');
const StorageTester = artifacts.require("./helpers/StorageUtilsTester.sol");

contract.only("StorageUtils - basic:", async (accounts) => {

  var storage;

  before(async () => {
    storage = await StorageTester.new();
  })

  context("Slot writes and reads", () => {
    let testVal1 = 5;
    let at1 = 2;
    let testVal2 = 7;
    let at2 = 5;

    it("Set one storage slot and read it", async () => {
      await storage.setUintAt(at1,testVal1);
      assert.equal((await storage.getUintAt.call(at1)), testVal1, "Should be equal");
    })

    it("Set other storage slot and read it", async () => {
      await storage.setUintAt(at2,testVal2);
      assert.equal((await storage.getUintAt.call(at2)), testVal2, "Should be equal");
    })

    it("Check if writes to slots are invariant to reads from non-overlaping slots", async () => {
      assert.equal((await storage.getUintAt.call(at1)), testVal1, "Should be equal");
    })

  })

  context("Multiple simultaneous slots writes and reads", () => {
    let values1 = [9,8,7];
    let at1 = 8;
    let values2 = [10,11,12];
    let at2 = 11;

    it("Set first array of values and read it", async () => {
      await storage.setManytUintAt(at1,values1);
      let got = await storage.getManyUintAt.call(at1,values1.length);
      values1.forEach( (v,i) => {
        assert.equal(got[i], v, "Should be equal");
      });
    })

    it("Set second array of values and read it", async () => {
      await storage.setManytUintAt(at2,values2);
      let got = await storage.getManyUintAt.call(at2,values2.length);
      values2.forEach( (v,i) => {
        assert.equal(got[i], v, "Should be equal");
      });
    })

    it("Check if writes to slots are invariant to reads from non-overlaping slots", async () => {
      let got = await storage.getManyUintAt.call(at1,values1.length);
      values1.forEach( (v,i) => {
        assert.equal(got[i], v, "Should be equal");
      });
    })

  })

})

contract.only("StorageUtils - helpers:", async (accounts) => {

  var storage;

  before(async () => {
    storage = await StorageTester.new();
  })

  context("Bytes type write and read", () => {
    let vals1 = "0x010203";
    let at1 = 1;
    let vals2 = "0x0a0b0c";
    let at2 = 2;

    it("Write first bytes array and read", async () => {
      await storage.setBytesAt(at1, vals1);
      assert.equal((await storage.getBytesAt.call(at1)), vals1, "Should be equal");
    })

    it("Write second bytes array and read", async () => {
      await storage.setBytesAt(at2, vals2);
      assert.equal((await storage.getBytesAt.call(at2)), vals2, "Should be equal");
    })

    it("Assert that simulated bytes array are stored in the same manner as 'classical'", async () => {
      assert.equal((await storage.getBytesAt.call(at1)), vals1, "Should be equal");
    })

  })

})
