const {assertRevert} = require('./helpers/assertThrow');
const StandardECMToken = artifacts.require("StandardECMToken");

contract("StandardECMToken transferFrom", async (accounts) => {

  const startBalance = 1000;
  let testWallet;

  before(async () => {
    testWallet = await StandardECMToken.deployed();
    await testWallet.payIn({from: accounts[0], value: startBalance});
  })

  it("test transfer 0", async () => {

    await testWallet.transferFrom(accounts[0], accounts[1], 0, {from: accounts[2]});
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
    assert.equal(
      (await testWallet.balanceOf.call(accounts[2])).toNumber(),
      0,
      "Should be "+0
    );
  })

  it("test transfer between different accounts", async () => {
    const amount = 500;

    await testWallet.approve(accounts[2], amount, {from: accounts[0]});

    await testWallet.transferFrom(accounts[0], accounts[1], amount, {from: accounts[2]});
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
    assert.equal(
      (await testWallet.balanceOf.call(accounts[2])).toNumber(),
      0,
      "Should be "+0
    );
  })

  it("test transfer within the same account", async () => {
    const amount = 500;

    await testWallet.approve(accounts[2], amount, {from: accounts[0]});

    await testWallet.transferFrom(accounts[0], accounts[0], amount, {from: accounts[2]});
    assert.equal(
      (await testWallet.balanceOf.call(accounts[0])).toNumber(),
      500,
      "Should be "+500
    );
  })

  it("test transfer more than available", async () => {
    const amount = 1000;

    await testWallet.approve(accounts[2], amount, {from: accounts[0]});

    await assertRevert(testWallet.transferFrom(accounts[0], accounts[1], amount, {from: accounts[2]}));

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
    assert.equal(
      (await testWallet.balanceOf.call(accounts[2])).toNumber(),
      0,
      "Should be "+0
    );
  })

})
