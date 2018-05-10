const AgreementManager = artifacts.require('AgreementManager');
const {createManyAgreements} = require('./helpers/agreementFactory');
const Agreement = artifacts.require('Agreement');
const {assertRevert} = require('./helpers/assertThrow');


contract("Test Agreement - Properties", async(accounts) =>
{
    const creator = accounts[0];
    let testManager;
    let agreement;

    before(async () =>
    {   
        testManager = await AgreementManager.deployed();
        let createTransactions = await createManyAgreements(testManager,[{address: creator, count: 1}]);
        agreement = await Agreement.at(createTransactions[0].logs[0].args.created);
        await agreement.join({from: accounts[1]});
        await agreement.join({from: accounts[2]});
        await agreement.join({from: accounts[3]});
        
    })

    it('Agreement should set to Running', async () =>
    {
        const Status = {New: 0,Running: 1, Done: 2};
        await agreement.accept(accounts[1], {from: creator});
        let RunningStatus = (await agreement.getStatus.call());
        assert.equal(RunningStatus,Status.Running,"Status should be set to Running");
    })

    it('Agreement cannot be remove if Status is set to running', async () =>
    {
        await assertRevert(agreement.remove());
    })
})