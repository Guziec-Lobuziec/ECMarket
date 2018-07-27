const AgreementManager = artifacts.require('AgreementManager');
const {createManyAgreements} = require('./helpers/agreementFactory');
const {AgreementEnumerations} = require('./helpers/Enumerations');
const Agreement1_1 = artifacts.require('Agreement1_1');
const {assertRevert} = require('./helpers/assertThrow');
const StandardECMToken = artifacts.require("StandardECMToken");

contract("Expiration Time A1.1 - join, accept, conclude", async(accounts) =>
{
    const creator = accounts[0];
    var tests = [
      {
        args: {
          address: creator,
          count: 1,
          expirationTime: 50,
          name: ["0","0"],
          description: ["0","0","0","0","0","0","0","0"]
        },
        blocksCount: 50
      },
      {
        args: {
          address: creator,
          count: 1,
          expirationTime: 100,
          name: ["0","0"],
          description: ["0","0","0","0","0","0","0","0"]
        },
        blocksCount: 110
      },
      {
        args: {
          address: creator,
          count: 1,
          expirationTime: 130,
          name: ["0","0"],
          description: ["0","0","0","0","0","0","0","0"]
        },
        blocksCount: 130
      }
    ];

    tests.forEach(function(test) {

      let agreement;
      let testManager;

      before(async () =>
      {
          testManager = await AgreementManager.deployed();
          let createTransactions = await createManyAgreements(
            testManager,
            [test.args]
          )
          agreement = await Agreement1_1.at(createTransactions[0].logs[0].args.created);

          await agreement.join({from: accounts[1]});
          await agreement.join({from: accounts[2]});
          await agreement.join({from: accounts[3]});

      })

      it('creating '+test.blocksCount+' blocks', async () =>
      {

          let blockBefore = await web3.eth.blockNumber;

          for (let i = 0; i < test.blocksCount; i++) {
              await web3.eth.sendTransaction({from: accounts[1],to: accounts[2]});
          }

          let numberOfBlocks = await web3.eth.blockNumber;

          assert.equal(
            numberOfBlocks,blockBefore+test.blocksCount,
            'Should have created '+test.blocksCount+' blocks'
          );
      })

      it('User cannot use join to agreement after '+test.blocksCount+' blocks', async () =>
      {
          await assertRevert(agreement.join({from: accounts[5]}));
      })

      it('User cannot accept agreement after '+test.blocksCount+' blocks', async () => {
          await assertRevert(agreement.accept(accounts[3], {from: creator}));
      })

      it('User cannot conclude agreement after '+test.blocksCount+' blocks', async () => {
          await assertRevert(agreement.conclude({from: accounts[2]}));
      })
    })

})

contract("Expiration Time - upper and lower limit (test env: upper 10000, lower: 10)", async(accounts) =>
{
    const creator = accounts[0];
    var tests = [
      {
        args: {
          address: creator,
          count: 1,
          expirationTime: 5,
          name: ["0","0"],
          description: ["0","0","0","0","0","0","0","0"]
        },
        expirationLimit: 10
      },
      {
        args: {
          address: creator,
          count: 1,
          expirationTime: 15000,
          name: ["0","0"],
          description: ["0","0","0","0","0","0","0","0"]
        },
        expirationLimit: 9999
      }
    ];

    tests.forEach(function(test) {

      let agreement;
      let testManager;

      before(async () =>
      {
          testManager = await AgreementManager.deployed();
          let createTransactions = await createManyAgreements(
            testManager,
            [test.args]
          )
          agreement = await Agreement1_1.at(createTransactions[0].logs[0].args.created);

      })

      it('testing expiration limit for '+test.expirationLimit, async () =>
      {
          assert.equal(
            await agreement.getBlocksToExpiration.call(),
            test.expirationLimit,
            'Should not pass given limit'
          )
      })
    })

})
