const {createManyAgreements} = require('./helpers/agreementFactory');
const {assertRevert} = require('./helpers/assertThrow');
const {AgreementEnumerations} = require('./helpers/Enumerations');
const AgreementManager = artifacts.require('AgreementManager');
const Agreement = artifacts.require('Agreement');
const StandardECMToken = artifacts.require("StandardECMToken");

contract('Agreement A1.1 - default path', async (accounts) => {

  const creator = accounts[0];
  const buyer = accounts[1];
  const suplicant1 = accounts[2];
  const price = 1000;
  const buyerBalance = 2000;
  const suplicantBalance = 2000;
  let testManager;
  let testWallet;
  let agreement;

  before(async () => {
    testManager = await AgreementManager.deployed();
    let createTransactions = await createManyAgreements(
      testManager, [{
        address: creator,
        count: 1,
        price: price,
        name: ["0","0"],
        description: ["0","0","0","0","0","0","0","0"]
      }]
    );
    agreement = await Agreement.at(createTransactions[0].logs[0].args.created);
    testWallet = await StandardECMToken.deployed();
    await testWallet.payIn({from: buyer, value: buyerBalance});
    await testWallet.payIn({from: suplicant1, value: suplicantBalance});
  })

  it('test price', async () => {
    assert.equal((await agreement.getPrice.call()).toNumber(), price, "Price should be "+price)
  })

  it('test if status is New', async () => {
    assert.equal(
      (await agreement.getStatus.call()),
      AgreementEnumerations.Status.New,
      "Status should be set to New"
    );
  })

  //creator i seller jednoczesnie

  it('join agreement - tokens transfer', async () => {
    assert.equal(
      (await testWallet.balanceOf.call(agreement.address)).toNumber(),
      0, "Agreement should have 0 (1)"
    );

    await testWallet.approve(agreement.address, price, {from: buyer});
    await agreement.join({from: buyer});
    assert.equal(
      (await testWallet.balanceOf.call(agreement.address)).toNumber(),
      price, "Agreement should have "+price+" (2)"
    );

    await testWallet.approve(agreement.address, price, {from: suplicant1});
    await agreement.join({from: suplicant1});
    assert.equal(
      (await testWallet.balanceOf.call(agreement.address)).toNumber(),
      price*2, "Agreement should have "+price*2+" (3)"
    );
  })

  it('check participants balances', async () => {
    assert.equal(
      (await testWallet.balanceOf.call(creator)).toNumber(),
      0, "Creator should have 0"
    );
    assert.equal(
      (await testWallet.balanceOf.call(buyer)).toNumber(),
      buyerBalance-price, "Buyer should have "+(buyerBalance-price)
    );
    assert.equal(
      (await testWallet.balanceOf.call(suplicant1)).toNumber(),
      suplicantBalance-price, "suplicant1 should have "+(buyerBalance-price)
    );
  })

  it('accept buyer - token transfer', async () => {
    await agreement.accept(buyer, {from: creator});

    assert.equal(
      (await testWallet.allowance.call(agreement.address, creator)).toNumber(),
      price,
      "Creator should be allowed to withdraw price: "+price
    );

  })

 // buyer ma miec role buyer

  it('test if status is Running', async () => {
    assert.equal(
      (await agreement.getStatus.call()),
      AgreementEnumerations.Status.Running,
      "Status should be set to Running"
    );
  })

  it('Test if agreement is set to Done', async () =>
  {
    const Status = {New: 0, Running: 1,Done: 2};

     await agreement.conclude({from: buyer});

     let afterBuyer= (await agreement.getStatus.call());
     assert.equal(afterBuyer,Status.Running, "Status should be set to Running ");

     await agreement.conclude({from: creator});

     let afterCreator= (await agreement.getStatus.call());
     assert.equal(afterCreator,Status.Done, "Status should be set to Done ");

  })

})
