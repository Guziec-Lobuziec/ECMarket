const AgreementManager = artifacts.require('AgreementManager');
const {createManyAgreements} = require('./helpers/agreementFactory');
const {AgreementEnumerations} = require('./helpers/Enumerations');
const Agreement = artifacts.require('Agreement');
const {assertRevert} = require('./helpers/assertThrow');
const VirtualWallet = artifacts.require("VirtualWallet");

contract('Test agreement flow cross-interactions with remove', async (accounts) => {
  const creator = accounts[0];
  let testManager;
  let agreement;

  before(async () =>
  {
      testManager = await AgreementManager.deployed();

      let createTransactions = await createManyAgreements(testManager,[{
        address: creator,
        count: 1,
        name: ["0","0"],
        description: ["0","0","0","0","0","0","0","0"]
      }]);
      agreement = await Agreement.at(createTransactions[0].logs[0].args.created);

  })

  it('test if join does not affect remove', async () => {
    await agreement.join({from: accounts[1]});
    await assertRevert(agreement.remove({from: accounts[1]}));
    await agreement.join({from: accounts[2]});
    await assertRevert(agreement.remove({from: accounts[2]}));
  })

  it('test if accept does not affect remove', async () => {
    await agreement.accept(accounts[1], {from: creator});
    await assertRevert(agreement.remove({from: accounts[1]}));
  })

  it('Agreement should set to Running', async () =>
  {
      let RunningStatus = (await agreement.getStatus.call());
      assert.equal(
        RunningStatus,
        AgreementEnumerations.Status.Running,
        "Status should be set to Running"
      );
  })

  it('Agreement cannot be remove if Status is set to running', async () =>
  {
      await assertRevert(agreement.remove({from: creator}));
  })

})
