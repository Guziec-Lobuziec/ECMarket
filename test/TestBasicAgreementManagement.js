var AgreementManager = artifacts.require("AgreementManager");

contract("Agreement basic management - removal", async (accounts) => {

  it("Test if agreement did selfdestruction", async () => {
    let testManager = await AgreementManager.deployed();

    let before = await testManager.search();
    assert.isTrue(before.every((e) => {return e == 0;}),'expected to be zeros before');

    let createTransaction = await testManager.create({from: accounts[0]});
    assert.equal(createTransaction.logs.length, 1, "one event generated");
    assert.equal(createTransaction.logs[0].event, "AgreementCreation", "event name");

    let agreement = createTransaction.logs[0].args.created;

    console.log(agreement);

    assert.notEqual(agreement, 0, 'should have valid address');

    let codeOfAgreementBefore = await web3.eth.getCode(agreement);
    assert.notEqual(codeOfAgreementBefore, "0x0", "should have some code");

    let agreements = await testManager.search();
    let one = agreements.filter((e) => {return e != 0;});
    assert.lengthOf(one, 1,'exactly one non zero');
    assert.include(one, [agreement], "manager should return the same address");

    await agreement.remove({from: accounts[0]});

    let codeOfAgreementAfter = await web3.eth.getCode(agreement);
    assert.equal(codeOfAgreementAfter, "0x0", "should have none");

    let after = await testManager.search();
    assert.isTrue(after.every((e) => {return e === 0;}),'expected to be zeros after');

  })

})
