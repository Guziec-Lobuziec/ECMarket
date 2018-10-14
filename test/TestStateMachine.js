const {assertRevert} = require('./helpers/assertThrow');
const StateMachine = artifacts.require("StateMachine");
const StateForTests = artifacts.require("./helpers/StateForTests.sol");

contract.only("StateMachine", async (accounts) => {

  var state;
  var machine;
  var stateInterface;

  before(async () => {
    state = await StateForTests.new();
    machine = await StateMachine.new(
      [state.address, state.address],
      [web3.toBigNumber(1),web3.toBigNumber(2)],
      [1,1],
      [web3.toBigNumber(2),web3.toBigNumber(1)],
      web3.toBigNumber(1)
    );
    stateInterface = await StateForTests.at(machine.address);
  })

  it("Simple state transition", async () => {

    let transaction = await stateInterface.test();
    assert.equal(transaction.logs[0].event, "Executed", "Event type should be 'Executed'");
    assert.equal(transaction.logs[0].args.what,"test()", "Event payload should be name of function");

  })

  it("State transition with input", async () => {

    let transaction = await stateInterface.transition(false);
    assert.equal(transaction.logs[0].event, "Executed", "Event type should be 'Executed'");
    assert.equal(
      transaction.logs[0].args.what,
      "transition(bool) false",
      "Event payload should be name of function and arg"
    );

  })

  it("State should not change", async () => {
    assert.equal(
      (await stateInterface.currentState.call()),
      '0x1000000000000000000000000000000000000000000000000000000000000000',
      "Should be in same"
    );
  })

  it("Flip state transition", async () => {

    let transaction = await stateInterface.transition(true);
    assert.equal(transaction.logs[0].event, "Executed", "Event type should be 'Executed'");
    assert.equal(
      transaction.logs[0].args.what,
      "transition(bool) true",
      "Event payload should be name of function and arg"
    );

  })

  it("Test if in next state", async () => {
    assert.equal(
      (await stateInterface.currentState.call()),
      '0x2000000000000000000000000000000000000000000000000000000000000000',
      "Should be in next state"
    );
  })

  it("Flop state transition", async () => {

    let transaction = await stateInterface.transition(true);
    assert.equal(
      (await stateInterface.currentState.call()),
      '0x1000000000000000000000000000000000000000000000000000000000000000',
      "Should be in previous state"
    );

  })

})
