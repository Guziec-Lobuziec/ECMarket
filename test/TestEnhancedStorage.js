const {assertRevert} = require('./helpers/assertThrow');
const StorageRangeTester = artifacts.require("./helpers/StorageRangeTester.sol");

contract.only("Enhanced Storage - storage pointer constraints:", async (accounts) => {

  var enhanced;
  before(async () => {
    enhanced = await StorageRangeTester.new();
  })

  it("Test if write and read works", async () => {
    let at = 0;
    let val = '0x0000000000000000000000000000000000000000000000000000000000000001';
    await enhanced.setByte32At(at,val)
    assert.equal((await enhanced.getByte32At.call(at)), val, "Should be equal");
  })

  it("Write to slot out of range ", async () => {
    let at = 16;
    let val = '0x0000000000000000000000000000000000000000000000000000000000000002';
    await assertRevert(enhanced.setByte32At(at,val));
  })

  it("Read from slot out of range ", async () => {
    let at = 16;
    await assertRevert(enhanced.getByte32At.call(at));
  })

  it("Test if writes and reads range does not apply for dynamic arrays", async () => {
    //bytes data location will be keccak256(1) = 0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf6
    let at = 1;
    let val = "0x0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f2021";
    await enhanced.setBytesAt(at,val);
    assert.equal((await enhanced.getBytesAt.call(at)), val, "Should be equal");
  })

  it("Test if data from different ranges occupy different slots", async () => {
    let at = 0;
    let val1 = '0x0000000000000000000000000000000000000000000000000000000000000001';
    let val2 = '0x0000000000000000000000000000000000000000000000000000000000000002';
    await enhanced.setByte32AtDifferentRange(at,val2)
    assert.equal((await enhanced.getByte32AtDifferentRange.call(at)), val2, "Should be equal");
    assert.equal((await enhanced.getByte32At.call(at)), val1, "Should be equal");
  })



})
