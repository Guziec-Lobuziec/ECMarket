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
    await stateInterface.setUint(1);
    assert.equal((await stateInterface.getUint.call()).toNumber(), 1, "Should be one");
  })

  it("Test adding multiple elements", async () => {
    let elements = [
      '0x1000000000000000000000000000000000000000000000000000000000000000',
      '0x2000000000000000000000000000000000000000000000000000000000000000',
      '0x3000000000000000000000000000000000000000000000000000000000000000'
    ];
    let transaction = await stateInterface.setBytes32Array(elements);
    console.log(transaction);
    let got = await stateInterface.getBytes32Array.call();
    elements.forEach( (e,i) => {
      assert.equal(got[i], e, "At index: "+i+" should be: "+e);
    })
  })

})
