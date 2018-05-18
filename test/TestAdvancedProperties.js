const {createManyAgreements} = require('./helpers/agreementFactory');
const {assertRevert} = require('./helpers/assertThrow');
const AgreementManager = artifacts.require('AgreementManager');
const Agreement = artifacts.require('Agreement');

contract('Test Advanced Properties', async (accounts) => {
    let testManager;

    before(async () => {
        testManager = await AgreementManager.deployed();
      })

    let name  = [
    "0x0000000000000000000000000000000000000000000000000000000000000033",
    "0x0000000000000000000000000000000000000000000000000000000000000044"
    ];

    let description  = [
        "0x0000000000000000000000000000000000000000000000000000000000000033",
        "0x0000000000000000000000000000000000000000000000000000000000000044",
        "0x0000000000000000000000000000000000000000000000000000000000000033",
        "0x0000000000000000000000000000000000000000000000000000000000000044",
        "0x0000000000000000000000000000000000000000000000000000000000000033",
        "0x0000000000000000000000000000000000000000000000000000000000000044",
        "0x0000000000000000000000000000000000000000000000000000000000000033",
        "0x0000000000000000000000000000000000000000000000000000000000000044"
      ];

    it('Agreement returns name', async () => {
        let transaction = await testManager.create(name, description, {from: accounts[0]});
        let agreementAdress = transaction.logs[0].args.created;
        let agreement = await Agreement.at(agreementAdress);
        let nameGot = await agreement.getName.call();
        assert.equal(nameGot[0], name[0], "Agreement doesn't return name (0)");
        assert.equal(nameGot[1], name[1], "Agreement doesn't return name (1)");

    })

    it('Agreement returns descyption', async () => {
        let transaction = await testManager.create(name, description, {from: accounts[0]});
        let agreementAdress = transaction.logs[0].args.created;
        let agreement = await Agreement.at(agreementAdress);
        let descriptionGot = await agreement.getDescription.call();
        assert.equal(descriptionGot[0], description[0], "Agreement doesn't return descryption (0)");
        assert.equal(descriptionGot[1], description[1], "Agreement doesn't return descryption (1)");
        assert.equal(descriptionGot[2], description[2], "Agreement doesn't return descryption (2)");
        assert.equal(descriptionGot[3], description[3], "Agreement doesn't return descryption (3)");
        assert.equal(descriptionGot[4], description[4], "Agreement doesn't return descryption (4)");
        assert.equal(descriptionGot[5], description[5], "Agreement doesn't return descryption (5)");
        assert.equal(descriptionGot[6], description[6], "Agreement doesn't return descryption (6)");
        assert.equal(descriptionGot[7], description[7], "Agreement doesn't return descryption (7)");

    })

})
