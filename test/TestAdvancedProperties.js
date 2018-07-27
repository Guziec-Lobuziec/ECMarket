const {createManyAgreements} = require('./helpers/agreementFactory');
const {assertRevert} = require('./helpers/assertThrow');
const AgreementManager = artifacts.require('AgreementManager');
const Agreement1_1 = artifacts.require('Agreement1_1');

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


    before(async () => {
        testManager = await AgreementManager.deployed();
        let transaction = await createManyAgreements(testManager,[{
          address: accounts[0],
          count: 1,
          name: name,
          description: description
        }]);
        let agreementAdress = transaction[0].logs[0].args.created;
        agreement = await Agreement1_1.at(agreementAdress);
      })

    it('Agreement1_1 returns name', async () => {

        let nameGot = await agreement.getName.call();
        assert.equal(nameGot[0], name[0], "Agreement1_1 doesn't return name (0)");
        assert.equal(nameGot[1], name[1], "Agreement1_1 doesn't return name (1)");

    })

    it('Agreement1_1 returns descyption', async () => {

        let descriptionGot = await agreement.getDescription.call();
        assert.equal(descriptionGot[0], description[0], "Agreement1_1 doesn't return descryption (0)");
        assert.equal(descriptionGot[1], description[1], "Agreement1_1 doesn't return descryption (1)");
        assert.equal(descriptionGot[2], description[2], "Agreement1_1 doesn't return descryption (2)");
        assert.equal(descriptionGot[3], description[3], "Agreement1_1 doesn't return descryption (3)");
        assert.equal(descriptionGot[4], description[4], "Agreement1_1 doesn't return descryption (4)");
        assert.equal(descriptionGot[5], description[5], "Agreement1_1 doesn't return descryption (5)");
        assert.equal(descriptionGot[6], description[6], "Agreement1_1 doesn't return descryption (6)");
        assert.equal(descriptionGot[7], description[7], "Agreement1_1 doesn't return descryption (7)");

    })

    it('Agreement1_1 JSON ABI', async () => {
        let testJSON = [
            {"name": "join","type": "function","inputs": [],"outputs": []},
            {"name": "accept","type": "function","inputs": [{"name": "suplicant","type": "address[64]"}],"outputs": []},
            {"name": "getParticipants","type": "function","inputs": [],"outputs": [{"type": "address[64]"}]},
            {"name": "getCreationBlock","type": "function","inputs": [],"outputs": [{"type": "uint256"}]},
            {"name": "getCreationTimestamp","type": "function","inputs": [],"outputs": [{"type": "uint256"}]},
            {"name": "getStatus","type": "function","inputs": [],"outputs": [{"type": "Status"}]},
            {"name": "conclude","type": "function","inputs": [],"outputs": []},
            {"name": "remove","type": "function","inputs": [],"outputs": []},
            {"name": "getName","type": "function","inputs": [],"outputs": [{"type": "bytes32[2]"}]},
            {"name": "getDescription","type": "function","inputs": [],"outputs": [{"type": "bytes32[8]"}]},
            {"name": "getPrice","type": "function","inputs":[],"outputs": [{"type": "uint256"}]}

        ];

        let agreementABIJSON = await agreement.getAPIJSON.call();

        let abi = [];
        try {
            abi = JSON.parse(agreementABIJSON);
        }
        catch (e) {
            assert.fail('invalid JSON');
        }

        let i;
        assert.equal(abi.length,testJSON.length, "Should have the same length");
        for(i = 0; i<testJSON.length; i++){
            assert.include(abi,testJSON[i], "ABI doesn't match given definition ("+i+")");
        }

        let testABI = web3.eth.contract(abi);
        let agreementWithABI = testABI.at(agreement.address);
        let gotName = await agreementWithABI.getName.call();

        assert.equal(gotName[0], name[0], "Should be equal (name0)");
        assert.equal(gotName[1], name[1], "Should be equal (name1)");
        assert.equal(
            (await agreementWithABI.getPrice.call()).toNumber(),
            (await agreement.getPrice.call()).toNumber(),
            "Price should be equal"
        );

    })

    //getparticipants razem z adresami role


})
