const {createManyAgreements} = require('./helpers/agreementFactory');
const {assertRevert} = require('./helpers/assertThrow');
const AgreementManager = artifacts.require('AgreementManager');
const Agreement = artifacts.require('Agreement');

contract('Test Advanced Properties', async (accounts) => {
    let testManager;

    before(async () => {
        testManager = await AgreementManager.deployed();
      })

    it('Agreement returns name', async () => {
        let transaction = await testManager.create("TestName", {from: accounts[0]});
        let agreementAdress = transaction.logs[0].args.created;
        let agreement = await Agreement.at(agreementAddress);
        let name = await agreement.getName.call();
        assert.equal(name, "TestName", "Agreement doesn't return name");

    })
    
})