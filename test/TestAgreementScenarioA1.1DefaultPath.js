const {createManyAgreements} = require('./helpers/agreementFactory');
const {assertRevert} = require('./helpers/assertThrow');
const AgreementManager = artifacts.require('AgreementManager');
const Agreement = artifacts.require('Agreement');
const VirtualWallet = artifacts.require("VirtualWallet");

contract('Agreement A1.1 - default path', async (accounts) => {

  const creator = accounts[0];
  const buyer = accounts[1];
  const suplicant = accounts[2];
  const price = 1000;
  let testManager;
  let testWallet;
  let agreement;

  before(async () => {
    testManager = await AgreementManager.deployed();
    let createTransactions = await createManyAgreements(
      testManager, [{address: creator, count: 1, price: price}]
    );
    agreement = await Agreement.at(createTransactions[0].logs[0].args.created);
    testWallet = await VirtualWallet.deployed();
    await testWallet.payIn({from: buyer, value: 2000});
    await testWallet.payIn({from: suplicant, value: 2000});
  })

  it('check price', async () => {
    assert.equal((await agreement.getPrice.call()), price, "Price should be "+price)
  })

  it('join agreement', async () => {

  })

})
