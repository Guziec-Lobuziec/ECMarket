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


    before(async () => {
        testManager = await AgreementManager.deployed();
        let transaction = await createManyAgreements(testManager,[{
          address: accounts[0],
          count: 1,
          name: name,
          description: description
        }]);
        let agreementAdress = transaction[0].logs[0].args.created;
        agreement = await Agreement.at(agreementAdress);
      })

    it('Agreement returns name', async () => {

        let nameGot = await agreement.getName.call();
        assert.equal(nameGot[0], name[0], "Agreement doesn't return name (0)");
        assert.equal(nameGot[1], name[1], "Agreement doesn't return name (1)");

    })

    it('Agreement returns descyption', async () => {

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

    it('Agreement JSON ABI', async () => {
        let testJSON = '[{"name": "join","type": "function","inputs": [],"outputs": []},' +
        '{"name": "accept","type": "function","inputs": [{"name": "suplicant","type": "address[64]",}],"outputs": []},' +
        '{"name": "getParticipants","type": "function","inputs": [],"outputs": [{"type": "address[64]"}]},' +
        '{"name": "getCreationBlock","type": "function","inputs": [],"outputs": [{"type": "uint"}]},' +
        '{"name": "getCreationTimestamp","type": "function","inputs": [],"outputs": [{"type": "uint"}]},' +
        '{"name": "getStatus","type": "function","inputs": [],"outputs": [{"type": "Status"}]},' +
        '{"name": "conclude","type": "function","inputs": [],"outputs": []},' +
        '{"name": "remove","type": "function","inputs": [],"outputs": []},' +
        '{"name": "getName","type": "function","inputs": [],"outputs": [{"type": "bytes32[2]"}]},' +
        '{"name": "getDescription","type": "function","inputs": [],"outputs": [{"type": "bytes32[8]"}]},';

        let agreementABIJSON = await agreement.getAPIJSON.call()
        assert.equal(agreementABIJSON, testJSON, "Agreement doesn't return JSON ABI");

        let testABI = web3.eth.contract(agreementABIJSON)

        assert.equal(testABI.getName.call(), name, "Should be equal");

    })
    //porównanie wykreowanego JSONA z tym zwracanym
    //https://github.com/ethereum/wiki/wiki/JavaScript-API#web3ethcontract
    //wywolanie metod


})
