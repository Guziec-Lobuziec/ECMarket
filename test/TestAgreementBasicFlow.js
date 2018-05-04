const {createManyAgreements} = require('./helpers/agreementFactory');
const {assertRevert} = require('./helpers/assertThrow');
const AgreementManager = artifacts.require('AgreementManager');
const Agreement = artifacts.require('Agreement');


contract('Agreement flow - joining', async (accounts) => {
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

  it('Test if suplicant or creator cannot double-join', async () => {
    let before = (await agreement.getParticipants.call()).filter((e) => {return e != 0;});

    await agreement.join({from: creator});

    let afterCreatorJoin = (await agreement.getParticipants.call()).filter((e) => {return e != 0;});
    assert.lengthOf(afterCreatorJoin, 3, "should have three participants");
    assert.include(
      afterCreatorJoin.toString(),
      [creator, accounts[1], accounts[2]],
      "Creator or suplicant missing"
    );

    let i;

    for(i = 0; i < afterCreatorJoin.length; i++) {
      assert.equal(afterCreatorJoin[i], before[i], "Should be in same order");
    }

    await agreement.join({from: accounts[2]});

    let afterSuplicantJoin = (await agreement.getParticipants.call()).filter((e) => {return e != 0;});
    assert.lengthOf(afterSuplicantJoin, 3, "should have three participants");
    assert.include(
      afterSuplicantJoin.toString(),
      [creator, accounts[1], accounts[2]],
      "Creator or suplicant missing"
    );

    for(i = 0; i < afterSuplicantJoin.length; i++) {
      assert.equal(afterSuplicantJoin[i], before[i], "Should be in same order");
    }
  })
})

contract('Agreement flow - accept properties', async (accounts) => {
  const creator = accounts[0];
  let testManager;
  let agreement;

  before(async () => {
    testManager = await AgreementManager.deployed();
    let createTransactions = await createManyAgreements(testManager, [{address: creator, count: 1}]);
    agreement = await Agreement.at(createTransactions[0].logs[0].args.created);
  })

  it('Test if creator fails to accept himself', async () => {

    await assertRevert(agreement.accept(creator, {from: creator}));

  })

  it('Test if creator fails to accept party, who didn\'t join', async () => {

    await assertRevert(agreement.accept(accounts[1], {from: creator}));

  })

  it('Only creator can accept others', async () => {

    await assertRevert(agreement.accept(accounts[2], {from: accounts[1]}), 'should revert (1)');
    await assertRevert(agreement.accept(accounts[2], {from: accounts[2]}), 'should revert (2)');

    await agreement.join({from: accounts[2]});
    await assertRevert(agreement.accept(accounts[2], {from: accounts[1]}), 'should revert (3)');
    await assertRevert(agreement.accept(accounts[2], {from: accounts[2]}), 'should revert (4)');
  })
})