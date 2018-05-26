const {createManyAgreements} = require('./helpers/agreementFactory');
const {assertRevert} = require('./helpers/assertThrow');
const {AgreementEnumerations} = require('./helpers/Enumerations');
const AgreementManager = artifacts.require('AgreementManager');
const Agreement = artifacts.require('Agreement');
const VirtualWallet = artifacts.require("VirtualWallet");

contract('Agreement A1.1 - exceptions', async (accounts) => {

  const creator = accounts[0];
  const buyer = accounts[1];
  const suplicant = accounts[2];
  const price = 2000;
  const buyerBalance = 4000;
  const suplicantBalance = 1000;
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
    await testWallet.payIn({from: buyer, value: buyerBalance});
    await testWallet.payIn({from: suplicant, value: suplicantBalance});
  })

  it('join agreement - insufficient funds', async () => {
    await assertRevert(agreement.join({from: suplicant}));
  })

})
