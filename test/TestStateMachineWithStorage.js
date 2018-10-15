const {assertRevert} = require('./helpers/assertThrow');
const StateMachineWithStorage = artifacts.require("StateMachineWithStorage");
const StateForTests3 = artifacts.require("./helpers/StateForTests3.sol");

contract.only("State Machine with storage", async (accounts) => {

  var state;
  var machine;
  var stateInterface;

  before(async () => {
    state = await StateForTests3.new();

    machine = await StateMachineWithStorage.new(
      [state.address, state.address],
      [web3.toBigNumber(1),web3.toBigNumber(2)],
      [1,1],
      [web3.toBigNumber(2),web3.toBigNumber(1)],
      web3.toBigNumber(1)
    );
    stateInterface = await StateForTests3.at(machine.address);
  })

  it("Test if value is set in storage", async () => {
    let transaction = await stateInterface.setUint(1);
    assert.equal((await stateInterface.getUint.call()).toNumber(), 1, "Should be one");
  })

})
