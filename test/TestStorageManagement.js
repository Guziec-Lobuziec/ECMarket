const {assertInvalidOpcode} = require('./helpers/assertThrow');
const StorageManagementTester = artifacts.require("./helpers/StorageManagementTester.sol");

contract("Storage Object", async (accounts) => {

  const magicNumber = '0xcafefeed000011110000111100001111000011110000111100001111cafefeed';

  context("StorageObject initialization", () => {

    var manager;
    before(async () => {
      manager = await StorageManagementTester.new();
    })

    it("Loading object before initialization should fail", async () => {
      await assertInvalidOpcode(manager.tryToGetStorageObject());
    })

    it("Setting invalid object location and trying to load", async () => {
      await manager.setInvalidStorageObjectLocation();
      await assertInvalidOpcode(manager.tryToGetStorageObject());
    })

    context("After initialization", () => {

      before(async () => {
        await manager.initStorageManagement();
      })

      it("Get StorageObject location", async () => {
        assert.equal((await manager.getStorageObjectLocation.call()), 2, "Should be in slot number 2");
      })

      it("Get StorageObject magic number", async () => {
        assert.equal(
          (await manager.getMagicNumberInStorageObject.call()),
          magicNumber,
          "Magic number should be present"
        );
      })
    })

  })


})
