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
        let name  = [
          "0x0000000000000000000000000000000000000000000000000000000000000033",
          "0x0000000000000000000000000000000000000000000000000000000000000044"
        ];
        let transaction = await testManager.create(name, {from: accounts[0]});
        let agreementAdress = transaction.logs[0].args.created;
        let agreement = await Agreement.at(agreementAdress);
        let nameGot = await agreement.getName.call();
        assert.equal(nameGot[0], name[0], "Agreement doesn't return name (0)");
        assert.equal(nameGot[1], name[1], "Agreement doesn't return name (1)");

    })

})
