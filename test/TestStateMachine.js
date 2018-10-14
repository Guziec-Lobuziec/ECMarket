const {assertRevert} = require('./helpers/assertThrow');
const StateMachine = artifacts.require("StateMachine");
const StateForTests1 = artifacts.require("./helpers/StateForTests1.sol");
const StateForTests2 = artifacts.require("./helpers/StateForTests2.sol");

contract.only("StateMachine", async (accounts) => {

  var state1;
  var state2;
  var machine;
  var stateInterface1;
  var stateInterface2;

  before(async () => {
    state1 = await StateForTests1.new();
    state2 = await StateForTests2.new();

    machine = await StateMachine.new(
      [state1.address, state1.address, state2.address],
      [web3.toBigNumber(1),web3.toBigNumber(2), web3.toBigNumber(3)],
      [1,2,1],
      [web3.toBigNumber(2),web3.toBigNumber(1),web3.toBigNumber(3),web3.toBigNumber(1)],
      web3.toBigNumber(1)
    );
    stateInterface1 = await StateForTests1.at(machine.address);
    stateInterface2 = await StateForTests2.at(machine.address);
  })

  it("Simple state transition", async () => {

    let transaction = await stateInterface1.test();
    assert.equal(transaction.logs[0].event, "Executed", "Event type should be 'Executed'");
    assert.equal(transaction.logs[0].args.what,"test()", "Event payload should be name of function");

  })

  it("State transition with input", async () => {

    let transaction = await stateInterface1.transition(false);
    assert.equal(transaction.logs[0].event, "Executed", "Event type should be 'Executed'");
    assert.equal(
      transaction.logs[0].args.what,
      "transition(bool) false",
      "Event payload should be name of function and arg"
    );

  })

  it("State should not change", async () => {
    assert.equal(
      (await stateInterface1.getMachineState.call()),
      '0x1000000000000000000000000000000000000000000000000000000000000000',
      "Should be in same"
    );
  })

  it("Test if state is assigned to given machine", async () =>{
    assert.equal(
      (await stateInterface1.getMachine.call()),
      machine.address,
      "Should return machine address"
    )
  })

  it("Flip state transition", async () => {

    let transaction = await stateInterface1.transition(true);
    assert.equal(transaction.logs[0].event, "Executed", "Event type should be 'Executed'");
    assert.equal(
      transaction.logs[0].args.what,
      "transition(bool) true",
      "Event payload should be name of function and arg"
    );

  })

  it("Test if transition do not change machine address", async () =>{
    assert.equal(
      (await stateInterface1.getMachine.call()),
      machine.address,
      "Should return machine address"
    )
  })

  it("Test if in next state", async () => {
    assert.equal(
      (await stateInterface1.getMachineState.call()),
      '0x2000000000000000000000000000000000000000000000000000000000000000',
      "Should be in next state"
    );
  })

  it("Check available states", async () =>{
    let states = [
      '0x1000000000000000000000000000000000000000000000000000000000000000',
      '0x3000000000000000000000000000000000000000000000000000000000000000'
    ];
    let got = await stateInterface1.getMachineReachableStates.call();
    states.forEach(s => {
      assert.include(got,s,"Should equal state: "+s);
    });

  })

  it("Flop state transition", async () => {

    let transaction = await stateInterface1.transition(true);
    assert.equal(
      (await stateInterface1.getMachineState.call()),
      '0x1000000000000000000000000000000000000000000000000000000000000000',
      "Should be in previous state"
    );

  })

  it("State with different code", async () =>{
    await stateInterface1.transition(true);
    await stateInterface1.differentCode();
    assert.equal(
      (await stateInterface2.getMachineState.call()),
      '0x3000000000000000000000000000000000000000000000000000000000000000',
      "Should be in previous state"
    );
  })

  it("Test if new transition is available", async () => {
    let transaction = await stateInterface2.uniqueForState();
    assert.equal(transaction.logs[0].event, "Executed", "Event type should be 'Executed'");
    assert.equal(
      transaction.logs[0].args.what,
      "uniqueForState()",
      "Event payload should be name of function"
    );
  })

  it("Try illegal state transition", async () => {
    await assertRevert(stateInterface1.transition(true))
  })

  it("Try transition to unreachable state", async () => {

    await assertRevert(stateInterface2.illegalTransition())
  })

  it("Step to next state", async () => {
    await stateInterface2.backToStart();
    assert.equal(
      (await stateInterface2.getMachineState.call()),
      '0x1000000000000000000000000000000000000000000000000000000000000000',
      "Should be in previous state"
    );
  })

  it("Only state code can alter machine", async () => {
    await assertRevert(
      machine.setNewState('0x3000000000000000000000000000000000000000000000000000000000000000')
    );
  })

  it("State contracts without machine are stateless", async () =>{
    await assertRevert(state1.getMachineState.call());
  })

  it("State is not machine", async () => {
    await assertRevert(state1.getMachine.call());
  })

  it("Machine defines reachable states", async () => {
    await assertRevert(state1.getMachineReachableStates.call());
  })

  it("State cannot perform transition without machine", async () => {
    await assertRevert(state1.transition(true));
  })

})
