var AgreementManager = artifacts.require("AgreementManager");
var Agreement = artifacts.require("Agreement");

contract("Agreement basic management - removal", async (accounts) => {

  it("Test if agreement did selfdestruction", async () => {
    let testManager = await AgreementManager.deployed();

    let before = await testManager.search();
    assert.isTrue(before.every((e) => {return e == 0;}),'expected to be zeros before');

    let createTransaction = await testManager.create({from: accounts[0]});
    assert.equal(createTransaction.logs.length, 1, "one event generated");
    assert.equal(createTransaction.logs[0].event, "AgreementCreation", "event name");

    let agreementAddress = createTransaction.logs[0].args.created;

    console.log(agreementAddress);

    assert.notEqual(agreementAddress, 0, 'should have valid address');

    let codeOfAgreementBefore = await web3.eth.getCode(agreementAddress);
    assert.notEqual(codeOfAgreementBefore, "0x0", "should have some code");

    let agreements = await testManager.search();
    let one = agreements.filter((e) => {return e != 0;});
    assert.lengthOf(one, 1,'exactly one non zero');
    assert.equal(one[0], agreementAddress, "manager should return the same address");

    let agreement = await Agreement.at(agreementAddress);
    await agreement.remove({from: accounts[0]});

    let codeOfAgreementAfter = await web3.eth.getCode(agreementAddress);
    assert.equal(codeOfAgreementAfter, "0x0", "should have none");

    let after = await testManager.search();
    assert.isTrue(after.every((e) => {return e == 0;}),'expected to be zeros after');

  })

})

contract("Agreement basic management - remove selected", async (accounts) => {

  it("Test if only selected agreement is removed", async () => {
    let testManager = await AgreementManager.deployed();

    let before = await testManager.search();
    assert.isTrue(before.every((e) => {return e == 0;}),'expected to be zeros before');

    let createTransaction1 = await testManager.create({from: accounts[0]});
    let createTransaction2 = await testManager.create({from: accounts[0]});

    let agreements = await testManager.search();
    assert.equal(agreements.filter((e) => {return e != 0;}).length, 2, "Should be two non zero records");

    let creationLogs = await (new Promise(function(resolve,reject) {
      testManager.AgreementCreation({},{fromBlock: 0, toBlock: 'latest'})
                                          .get((error, eventResult) => {
                                            if(error)
                                              return reject(error);
                                            else
                                              return resolve(eventResult);
                                          });
    }));

    console.log(creationLogs.map((l) => {return l.args.created}));
    assert.equal(creationLogs.length, 2, "Should be two events");
    assert.include(
      agreements.toString(),
      creationLogs.map((l) => {return l.args.created}),
      "Search and logs should match"
    );

    let createdAgreements = agreements.filter((e) => {return e != 0;});
    let agreementToBeRemoved = await Agreement.at(createdAgreements[0]);
    await agreementToBeRemoved.remove({from: accounts[0]});

    let after = await testManager.search();
    assert.notInclude(after, createdAgreements[0],'no longer exists');
    assert.include(after, createdAgreements[1], 'second agreement still tracked');
    assert.equal(await web3.eth.getCode(createdAgreements[0]), '0x0', "destroyed");
    assert.notEqual(await web3.eth.getCode(createdAgreements[1]), '0x0', "untouched");

  })

})
