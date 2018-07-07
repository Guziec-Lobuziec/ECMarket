const {assertRevert} = require('./helpers/assertThrow');
const StandardECMToken = artifacts.require("StandardECMToken");

contract("StandardECMToken transferFrom", async (accounts) => {

  const startBalance = 1000;
  let testWallet;
  let transaction;

  before(async () => {
    testWallet = await StandardECMToken.deployed();
    await testWallet.payIn({from: accounts[0], value: startBalance});
  })

  it("test transfer 0", async () => {

    transaction = await testWallet.transferFrom(accounts[0], accounts[1], 0, {from: accounts[2]});
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

  it("transfer zero tokens event", async () => {
    assert.equal(transaction.logs[0].args._from, accounts[0], "Sholud be accounts[0]");
    assert.equal(transaction.logs[0].args._to, accounts[1], "Sholud be accounts[1]");
    assert.equal(transaction.logs[0].args._value, 0, "Sholud be "+0);
  })

  it("test transfer between different accounts", async () => {
    const amount = 500;

    await testWallet.approve(accounts[2], amount, {from: accounts[0]});

    transaction =  await testWallet.transferFrom(accounts[0], accounts[1], amount, {from: accounts[2]});
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

  it("transfer 500 tokens event", async () => {
    assert.equal(transaction.logs[0].args._from, accounts[0], "Sholud be accounts[0]");
    assert.equal(transaction.logs[0].args._to, accounts[1], "Sholud be accounts[1]");
    assert.equal(transaction.logs[0].args._value, 500, "Sholud be "+500);
  })

  it("test transfer within the same account", async () => {
    const amount = 500;

    await testWallet.approve(accounts[2], amount, {from: accounts[0]});

    transaction =  await testWallet.transferFrom(accounts[0], accounts[0], amount, {from: accounts[2]});
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

  it("test if transferFrom cannot send tokens to 0x0 or token contract address", async () => {
    await assertRevert(
      testWallet.transferFrom(accounts[0], 0, 500, {from: accounts[2]}),
      "sending to 0x0"
    );
    await assertRevert(
      testWallet.transferFrom(accounts[0], testWallet.address, 500, {from: accounts[2]}),
      "sending to token contract address"
    );
  })

})

contract("StandardECMToken approve and allowance", async (accounts) => {
  const startBalance = 1000;
  let testWallet;
  let transaction;

  before(async () => {
    testWallet = await StandardECMToken.deployed();
    await testWallet.payIn({from: accounts[0], value: startBalance});
  })

  it("test allowance return value", async () => {
    let amount = 1000;
    transaction = await testWallet.approve(accounts[1], amount, {from: accounts[0]});
    assert.equal(
      (await testWallet.allowance.call(accounts[0],accounts[1])).toNumber(),
      amount,
      "allowance should equal "+amount+" from accounts[0] to accounts[1]"
    );
    assert.equal(
      (await testWallet.allowance.call(accounts[1],accounts[0])).toNumber(),
      0,
      "allowance should equal "+amount+" from accounts[1] to accounts[0]"
    );
  })

  it("approve 1000 tokens event", async () => {
    assert.equal(transaction.logs[0].args._owner, accounts[0], "Sholud be accounts[0]");
    assert.equal(transaction.logs[0].args._spender, accounts[1], "Sholud be accounts[1]");
    assert.equal(transaction.logs[0].args._value, 1000, "Sholud be "+1000);
  })

  it("test allowance after transferFrom", async () => {
    let amount = 1000;
    await testWallet.transferFrom(accounts[0], accounts[2], amount, {from: accounts[1]})
    assert.equal(
      (await testWallet.allowance.call(accounts[0],accounts[1])).toNumber(),
      0,
      "allowance should equal "+0+" from accounts[0] to accounts[1]"
    );
  })

  it("test transferFrom when not allowed", async () => {
    let amount = 1000;
    await assertRevert(testWallet.transferFrom(accounts[2], accounts[0], amount, {from: accounts[1]}));
  })

  it("test consecutive nonzero approve calls", async () => {
    await testWallet.approve(accounts[1], 500, {from: accounts[2]});
    await assertRevert(testWallet.approve(accounts[1], 1000, {from: accounts[2]}));
  })

  it("test consecutive zero and nonzero approve calls", async () => {
    await testWallet.approve(accounts[1], 0, {from: accounts[2]});
    assert.equal(
      (await testWallet.allowance.call(accounts[2],accounts[1])).toNumber(),
      0,
      "allowance should equal "+0+" from accounts[2] to accounts[1]"
    );
    await testWallet.approve(accounts[1], 1000, {from: accounts[2]});
    assert.equal(
      (await testWallet.allowance.call(accounts[2],accounts[1])).toNumber(),
      1000,
      "allowance should equal "+1000+" from accounts[2] to accounts[1]"
    );
  })
})
