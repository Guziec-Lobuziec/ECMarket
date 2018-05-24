const {assertRevert} = require('./helpers/assertThrow');
const VirtualWallet = artifacts.require("VirtualWallet");

contract("VirtualWallet transfer", async (accounts) => {

  const startBalance = 1000;
  let testWallet;

  before(async () => {
    testWallet = await VirtualWallet.deployed();
    await testWallet.payIn({from: accounts[0], value: startBalance});
  })

  it("test transfer 0", async () => {
    await testWallet.transfer(accounts[1], 0, {from: accounts[0]});
    assert.equal(
      (await testWallet.balanceOf.call(accounts[0])).toNumber(),
      startBalance,
      "Should be "+startBalance
    );
    assert.equal(
      (await testWallet.balanceOf.call(accounts[1])).toNumber(),
      0,
      "Should be "+0
    );
  })

  it("test transfer between different accounts", async () => {
    const amount = 500;
    await testWallet.transfer(accounts[1], amount, {from: accounts[0]});
    assert.equal(
      (await testWallet.balanceOf.call(accounts[0])).toNumber(),
      startBalance-amount,
      "Should be "+startBalance-amount
    );
    assert.equal(
      (await testWallet.balanceOf.call(accounts[1])).toNumber(),
      amount,
      "Should be "+amount
    );
  })

  it("test transfer within the same account", async () => {
    const amount = 500;
    await testWallet.transfer(accounts[0], amount, {from: accounts[0]});
    assert.equal(
      (await testWallet.balanceOf.call(accounts[0])).toNumber(),
      500,
      "Should be "+500
    );
  })

  it("test transfer more than available", async () => {
    const amount = 1000;
    await assertRevert(testWallet.transfer(accounts[1], amount, {from: accounts[0]}));

    assert.equal(
      (await testWallet.balanceOf.call(accounts[0])).toNumber(),
      500,
      "Should be "+500
    );
    assert.equal(
      (await testWallet.balanceOf.call(accounts[1])).toNumber(),
      500,
      "Should be "+500
    );
  })

})

contract("VirtualWallet transferFrom", async (accounts) => {

  const startBalance = 1000;
  let testWallet;

  before(async () => {
    testWallet = await VirtualWallet.deployed();
    await testWallet.payIn({from: accounts[0], value: startBalance});
  })

  it("test transfer 0", async () => {
    await testWallet.transfer(accounts[0], 0, {from: accounts[2]});

  })

})
