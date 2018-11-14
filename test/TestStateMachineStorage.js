const {assertRevert} = require('./helpers/assertThrow');
const StateMachineWithStorage = artifacts.require("./helpers/StateMachineWithStorage.sol");
const StateWithStorage = artifacts.require("./helpers/StateWithStorageTest.sol");

contract("StateMachine with storage:", async (accounts) => {

  var state;
  var machine;
  var stateInterface;

  before(async () => {
    state = await StateWithStorage.new();
    machine = await StateMachineWithStorage.new(
      [state.address, state.address],
      [web3.toBigNumber(1),web3.toBigNumber(2)],
      [1,1],
      [web3.toBigNumber(2),web3.toBigNumber(1)],
      web3.toBigNumber(1)
    );
    stateInterface = await StateWithStorage.at(machine.address);
  })

  context("Set value for 1st state", () => {

    var val1 = '0x0000000000000000000000000000000000000000000000000000000000000005';
    it("Test if set successfully", async () => {
      await stateInterface.setBytes32(val1);
      assert.equal(
        (await stateInterface.getBytes32.call()),
        val1,
        "Should be set"
      );
    })

    context("Move to next state and set another value", () => {

      var val2 = '0x0000000000000000000000000000000000000000000000000000000000000003';

      before(async () => {
        await stateInterface.transition();
      })

      it("Check if is zero at begining", async () => {
        assert.equal(
          (await stateInterface.getBytes32.call()),
          '0x0000000000000000000000000000000000000000000000000000000000000000',
          "Should be zero"
        );
      })

      it("Test if set successfully", async () => {
        await stateInterface.setBytes32(val2);
        assert.equal(
          (await stateInterface.getBytes32.call()),
          val2,
          "Should be set"
        );
      })

      after(async () => {
        await stateInterface.transition();
      })

    })

    it("Check if state values are separated", async () => {
      assert.equal(
        (await stateInterface.getBytes32.call()),
        val1,
        "Should be set"
      );
    })

  })

})
