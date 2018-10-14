const {assertRevert} = require('./helpers/assertThrow');
const StateMachine = artifacts.require("StateMachine");
const StateWithStorage = artifacts.require("./helpers/StateWithStorage.sol");

contract.only("State Machine with storage", async (accounts) => {

  var state;
  var machine;
  var stateInterface;

  before(async () => {
    state = await StateWithStorage.new();

    machine = await StateMachine.new(
      [state.address, state.address],
      [web3.toBigNumber(1),web3.toBigNumber(2)],
      [1,1],
      [web3.toBigNumber(2),web3.toBigNumber(1)],
      web3.toBigNumber(1)
    );
    stateInterface = await StateWithStorage.at(machine.address);
  })

  it("Test if value is set in storage", async () => {
    await stateInterface.setUint(1);
    assert.equal((await stateInterface.getUint.call()), 1, "Should be one");
  })

})
