const {createManyAgreements} = require('./helpers/agreementFactory');
const {assertRevert} = require('./helpers/assertThrow');
const {AgreementEnumerations} = require('./helpers/Enumerations');
const AgreementManager = artifacts.require('AgreementManager');
const Agreement = artifacts.require('Agreement');
const StandardECMToken = artifacts.require("StandardECMToken");

contract('Agreement 1.1 flow - joining properties', async (accounts) => {
  const creator = accounts[0];
  let testManager;
  let agreement;

  before(async () => {
    testManager = await AgreementManager.deployed();
    let createTransactions = await createManyAgreements(testManager, [{
      address: creator,
      count: 1,
      name: ["0","0"],
      description: ["0","0","0","0","0","0","0","0"]
    }]);
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

  it('Cannot join if agreement is Running', async () => {
    await agreement.accept(accounts[1], {from: creator});
    await assertRevert(agreement.join({from: accounts[3]}));
  })

  it('Cannot join if agreement is Done', async () => {
    await agreement.conclude({from: creator});
    await agreement.conclude({from: accounts[1]});
    await assertRevert(agreement.join({from: accounts[3]}));
  })

})

contract('Agreement 1.1 flow - accept permissions related properties', async (accounts) => {
  const creator = accounts[0];
  let testManager;
  let agreement;

  before(async () => {
    testManager = await AgreementManager.deployed();
    let createTransactions = await createManyAgreements(testManager, [{
      address: creator,
      count: 1,
      name: ["0","0"],
      description: ["0","0","0","0","0","0","0","0"]
    }]);
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

contract('Agreement 1.1 flow - accept state related properties', async (accounts) => {
  const creator = accounts[0];
  let testManager;
  let agreement;

  before(async () => {
    testManager = await AgreementManager.deployed();
    let createTransactions = await createManyAgreements(testManager, [{
      address: creator,
      count: 1,
      name: ["0","0"],
      description: ["0","0","0","0","0","0","0","0"]
    }]);
    agreement = await Agreement.at(createTransactions[0].logs[0].args.created);
    await agreement.join({from: accounts[2]});
    await agreement.join({from: accounts[3]});
  })

  it('Cannot double accept', async () => {
    await agreement.accept(accounts[2], {from: creator});
    await assertRevert(agreement.accept(accounts[2], {from: creator}));
  })

  it('Cannot accept if agreement is Done', async () => {
    assert.equal(
      (await agreement.getStatus.call()),
      AgreementEnumerations.Status.Running,
      "Status should be set to Running"
    );
    await agreement.conclude({from: creator});
    await agreement.conclude({from: accounts[2]});
    await assertRevert(agreement.accept(accounts[3], {from: creator}));
  })
})

contract('Agreement 1.1 flow - conclude properties', async (accounts) => {
  const creator = accounts[0];
  const suplicant = accounts[1];
  let testManager;
  let agreement;

  before(async () => {
    testManager = await AgreementManager.deployed();
    let createTransactions = await createManyAgreements(testManager, [{
      address: creator,
      count: 1,
      name: ["0","0"],
      description: ["0","0","0","0","0","0","0","0"]
    }]);
    agreement = await Agreement.at(createTransactions[0].logs[0].args.created);
  })

  it('Test if alien address cannot conclude agreement', async () => {
    await assertRevert(agreement.conclude({from: suplicant}),'Address is not part of agreement');
  })

  it('Test if not accepted address cannot conclude agreement', async () => {
    await agreement.join({from: suplicant});
    await assertRevert(agreement.conclude({from: suplicant}),'Address is not part of agreement');
  })

  it('Test if agreement cannot be concluded status before Running status', async () => {
    assert.equal(
      (await agreement.getStatus.call()),
      AgreementEnumerations.Status.New,
      "Status should be set to New"
    );

    await assertRevert(agreement.conclude({from: creator}),'If reach Done before Running should revert');
  })

  it('Cannot double conclude', async () => {
    await agreement.accept(suplicant, {from: creator});
    await agreement.conclude({from: creator});
    await assertRevert(agreement.conclude({from: creator}));
  })

})

contract('Funds related tests', async (accounts) => {

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
      testManager, [{
        address: creator,
        count: 1,
        name: ["0","0"],
        description: ["0","0","0","0","0","0","0","0"],
        price: price
      }]
    );
    agreement = await Agreement.at(createTransactions[0].logs[0].args.created);
    testWallet = await StandardECMToken.deployed();
    await testWallet.payIn({from: buyer, value: buyerBalance});
    await testWallet.payIn({from: suplicant, value: suplicantBalance});
    await testWallet.approve(agreement.address, price, {from: suplicant})
  })

  it('join agreement - insufficient funds', async () => {
    await assertRevert(agreement.join({from: suplicant}));
  })

})
