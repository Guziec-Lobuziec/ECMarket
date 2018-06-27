const AgreementManager = artifacts.require('AgreementManager');
const {createManyAgreements} = require('./helpers/agreementFactory');
const {AgreementEnumerations} = require('./helpers/Enumerations');
const Agreement = artifacts.require('Agreement');
const {assertRevert} = require('./helpers/assertThrow');
const VirtualWallet = artifacts.require("VirtualWallet");

contract('Test agreement flow cross-interactions with remove', async (accounts) => {
  const creator = accounts[0];
  let testManager;
  let agreement;

  before(async () =>
  {
      testManager = await AgreementManager.deployed();

      let createTransactions = await createManyAgreements(testManager,[{
        address: creator,
        count: 1,
        name: ["0","0"],
        description: ["0","0","0","0","0","0","0","0"]
      }]);
      agreement = await Agreement.at(createTransactions[0].logs[0].args.created);

  })

  it('test if join does not affect remove', async () => {
    await agreement.join({from: accounts[1]});
    await assertRevert(agreement.remove({from: accounts[1]}));
    await agreement.join({from: accounts[2]});
    await assertRevert(agreement.remove({from: accounts[2]}));
  })

  it('test if accept does not affect remove', async () => {
    await agreement.accept(accounts[1], {from: creator});
    await assertRevert(agreement.remove({from: accounts[1]}));
  })

  it('Agreement should set to Running', async () =>
  {
      let RunningStatus = (await agreement.getStatus.call());
      assert.equal(
        RunningStatus,
        AgreementEnumerations.Status.Running,
        "Status should be set to Running"
      );
  })

  it('Agreement cannot be remove if Status is set to running', async () =>
  {
      await assertRevert(agreement.remove({from: creator}));
  })

})



contract("Test Agreement Properties - Expiration Time", async(accounts) =>
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
          agreement = await Agreement.at(createTransactions[0].logs[0].args.created);

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
