const {createManyAgreements} = require('./helpers/agreementFactory');
const {assertRevert} = require('./helpers/assertThrow');
const {AgreementEnumerations} = require('./helpers/Enumerations');
const AgreementManager = artifacts.require('AgreementManager');
const Agreement = artifacts.require('Agreement');
const StandardECMToken = artifacts.require("StandardECMToken");

contract.skip('Agreement 1.2 - default path', async (accounts) => {
  const creator = accounts[0];
  const buyer = accounts[1];
  const suplicant1 = accounts[2];
  const price = 1000;
  const advancePayment = 250;
  const timeToFallback = 5;
  const buyerBalance = 2000;
  const suplicantBalance = 2000;

  let testManager;
  let testWallet;
  let agreement;

  before(async () => {
    testManager = await AgreementManager.deployed();

    let createTransactions = await createManyAgreements(
      testManager,
      [{
        address: creator,
        count: 1,
        name: ["0","0"],
        description: ["0","0","0","0","0","0","0","0"],
        price: price,
        extra: [{name: "setAdvancePayment", args:[advancePayment,timeToFallback]}]
      }]
    );

    agreement = await Agreement.at(createTransactions[0].logs[0].args.created);
    testWallet = await StandardECMToken.deployed();
    await testWallet.payIn({from: buyer, value: buyerBalance});
    await testWallet.payIn({from: suplicant1, value: suplicantBalance});
  })

  it('test if Agreement 1.2 has advancePayment', async () => {
    assert.equal(
      await agreement.getAdvancePayment.call(),
      advancePayment,
      "getAdvancePayment should return "+advancePayment
    );
  })

  it('test if Agreement 1.2 has blocksToFallback', async () => {
    assert.equal(
      await agreement.getBlocksToFallback.call(),
      timeToFallback,
      "getBlocksToFallback should return "+timeToFallback
    );
  })
})
