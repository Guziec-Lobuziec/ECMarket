const {createManyAgreements} = require('./helpers/agreementFactory');
const BigNumber = require('bignumber.js');
const AgreementManager = artifacts.require('AgreementManager');
const Agreement = artifacts.require('Agreement');


contract('Agreement flow', async (accounts) => {
  const creator = accounts[0];
  let testManager;
  let agreement;

  before(async () => {
    testManager = await AgreementManager.deployed();
    let createTransactions = await createManyAgreements(testManager, [{address: creator, count: 1}]);
    agreement = await Agreement.at(createTransactions[0].logs[0].args.created);
  })

  it('Test joining agreement', async () => {

    let participantsBefore = (await agreement.getParticipants.call()).filter((e) => {return e != 0;});
    assert.lengthOf(participantsBefore, 1, "should have one participant");

    await agreement.join({from: accounts[1]});

    let participants = (await agreement.getParticipants.call()).filter((e) => {return e != 0;});
    assert.lengthOf(participants, 2, "should have two participants");

    assert.include(
      participants.toString(),
      [creator, accounts[1]],
      "Creator or suplicant missing"
    );
  })

  it('Test joining agreement - multiple suplicants', async () => {
    await agreement.join({from: accounts[2]});

    let participants = (await agreement.getParticipants.call()).filter((e) => {return e != 0;});
    assert.lengthOf(participants, 3, "should have three participants");

    assert.include(
      participants.toString(),
      [creator, accounts[1], accounts[2]],
      "Creator or suplicant missing"
    );
  })
})
