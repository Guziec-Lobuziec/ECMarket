const AgreementManager = artifacts.require('AgreementManager');
const {createManyAgreements} = require('./helpers/agreementFactory');
const {AgreementEnumerations} = require('./helpers/Enumerations');
const Agreement = artifacts.require('Agreement');
const {assertRevert} = require('./helpers/assertThrow');
const StandardECMToken = artifacts.require("StandardECMToken");
var AgreementStates = [artifacts.require("EntryState"),artifacts.require("RunningState")];

contract('Test agreement flow cross-interactions with remove', async (accounts) => {
  const creator = accounts[0];
  let testManager;
  let agreement;
  let agreementInterfaces = [];

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

      agreementInterfaces = await Promise.all(
        AgreementStates.map(stateI => stateI.at(agreement.address))
      );
  })

  it('test if join does not affect remove', async () => {
    await agreementInterfaces[0].join({from: accounts[1]});
    await assertRevert(agreementInterfaces[0].remove({from: accounts[1]}));
    await agreementInterfaces[0].join({from: accounts[2]});
    await assertRevert(agreementInterfaces[0].remove({from: accounts[2]}));
  })

  it('test if accept does not affect remove', async () => {
    await agreementInterfaces[0].accept(accounts[1], {from: creator});
    await assertRevert(agreementInterfaces[0].remove({from: accounts[1]}));
  })

  it('Agreement 1.1 should set to Running', async () =>
  {
      let RunningStatus = (await agreementInterfaces[1].getStatus.call());
      assert.equal(
        RunningStatus,
        AgreementEnumerations.Status.Running,
        "Status should be set to Running"
      );
  })

  it('Agreement 1.1 cannot be remove if Status is set to running', async () =>
  {
      await assertRevert(agreementInterfaces[0].remove({from: creator}));
  })

})
