const {createManyAgreements} = require('./helpers/agreementFactory');
const {assertRevert} = require('./helpers/assertThrow');
const AgreementManager = artifacts.require('AgreementManager');
const Agreement = artifacts.require('Agreement');

contract('Test Advanced Properties', async (accounts) => {
    let testManager;
    let agreement;

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

    let expirationTime = 1000;
    let creationBlock = 0;


    before(async () => {
        testManager = await AgreementManager.deployed();
        let transaction = await createManyAgreements(testManager,[{
          address: accounts[0],
          count: 1,
          name: name,
          description: description,
          expirationTime: expirationTime
        }]);
        let agreementAdress = transaction[0].logs[0].args.created;
        agreement = await Agreement.at(agreementAdress);
        creationBlock = transaction[0].receipt.blockNumber;
      })

    it('Agreement returns name', async () => {

        let nameGot = await agreement.getName.call();
        assert.equal(nameGot.length, name.length, "set and returned names should have the same length");
        name.forEach((e,i) => {
          assert.equal(nameGot[i], e, "Element ("+i+") should match");
        });

    })

    it('Agreement returns descyption', async () => {

        let descriptionGot = await agreement.getDescription.call();
        assert.equal(
          descriptionGot.length,
          description.length,
          "set and returned desciptions should have the same length"
        );
        description.forEach((e,i) => {
          assert.equal(descriptionGot[i], e, "Element ("+i+") should match");
        });

    })

    it('Agreement returns creation block', async () => {
        assert.equal(
          (await agreement.getCreationBlock.call()),
          creationBlock,
          "Should be equal"
        );
    })

    it('Agreement returns creation timestamp', async () => {
        assert.isAbove(
          (await agreement.getCreationTimestamp.call()).toNumber(),
          0,
          "Timestamp should be greater then 0"
        );
    })

    it('Agreement returns blocks to expiration', async () => {
        assert.equal(
          (await agreement.getBlocksToExpiration.call()),
          expirationTime,
          "Should be equal"
        );
    })


})
