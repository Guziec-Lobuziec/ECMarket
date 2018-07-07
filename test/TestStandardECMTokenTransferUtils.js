const {assertRevert} = require('./helpers/assertThrow');
const StandardECMToken = artifacts.require("StandardECMToken");

contract("StandardECMToken transfer", async (accounts) => {

  const startBalance = 1000;
  let testWallet;
  let transaction;

  before(async () => {
    testWallet = await StandardECMToken.deployed();
    await testWallet.payIn({from: accounts[0], value: startBalance});
  })

  it("test transfer 0", async () => {
    transaction = await testWallet.transfer(accounts[1], 0, {from: accounts[0]});
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

  it("transfer zero tokens event", async () => {
    assert.equal(transaction.logs[0].args._from, accounts[0], "Sholud be accounts[0]");
    assert.equal(transaction.logs[0].args._to, accounts[1], "Sholud be accounts[1]");
    assert.equal(transaction.logs[0].args._value, 0, "Sholud be "+0);
  })

  it("test transfer between different accounts", async () => {
    const amount = 500;
    transaction = await testWallet.transfer(accounts[1], amount, {from: accounts[0]});
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

  it("transfer 500 tokens event", async () => {
    assert.equal(transaction.logs[0].args._from, accounts[0], "Sholud be accounts[0]");
    assert.equal(transaction.logs[0].args._to, accounts[1], "Sholud be accounts[1]");
    assert.equal(transaction.logs[0].args._value, 500, "Sholud be "+500);
  })

  it("test transfer within the same account", async () => {
    const amount = 500;
    transaction = await testWallet.transfer(accounts[0], amount, {from: accounts[0]});
    assert.equal(
      (await testWallet.balanceOf.call(accounts[0])).toNumber(),
      500,
      "Should be "+500
    );
  })

  it("transfer within the same account event test", async () => {
    assert.equal(transaction.logs[0].args._from, accounts[0], "Sholud be accounts[0]");
    assert.equal(transaction.logs[0].args._to, accounts[0], "Sholud be accounts[0]");
    assert.equal(transaction.logs[0].args._value, 500, "Sholud be "+500);
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

  it("test if transfer cannot send tokens to 0x0 or token contract address", async () => {
    await assertRevert(
      testWallet.transfer(0, 500, {from: accounts[0]}),
      "sending to 0x0"
    );
    await assertRevert(
      testWallet.transfer(testWallet.address, 500, {from: accounts[0]}),
      "sending to token contract address"
    );
  })

})
