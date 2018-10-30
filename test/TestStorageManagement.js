const {assertInvalidOpcode} = require('./helpers/assertThrow');
const StorageManagementTester = artifacts.require("./helpers/StorageManagementTester.sol");

contract.only("Storage Object", async (accounts) => {

  context("StorageObject initialization", () => {

    var manager;
    before(async () => {
      manager = await StorageManagementTester.new();
    })

    it("Loading object before initialization should fail", async () => {
      await assertInvalidOpcode(manager.tryToGetStorageObject());
    })

    it("After initialization", async () => {
      await manager.initStorageManagement();
      await manager.tryToGetStorageObject();
    })

  })


})
