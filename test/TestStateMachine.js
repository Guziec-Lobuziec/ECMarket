const {assertRevert} = require('./helpers/assertThrow');
const StateMachine = artifacts.require("StateMachine");
const StateForTests = artifacts.require("./helpers/StateForTests.sol");

contract.only("StateMachine", async (accounts) => {

  var machine;

  before(async () => {
    state = await StateForTests.new();
    machine = await StateMachine.new(
      [state.address], ["1"], [1], ["1"], "1"
    );
  })

  it("State transition", async () => {

    let testState = await StateForTests.at(machine.address);
    let transaction = await testState.test();
    assert.equal(transaction.logs[0].event, "Executed", "Event type should be 'Executed'");
    assert.equal(transaction.logs[0].args.what,"test()", "Event payload should be name of function");
    
  })

})
