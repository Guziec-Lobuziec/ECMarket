pragma solidity 0.4.23;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

import "../contracts/AgreementManager.sol";


contract TestAgreement {

    function testAgreementDefaultProperties() {

        AgreementManager testManager = AgreementManager(DeployedAddresses.AgreementManager());

        Agreement1_1 testAgreement = Agreement1_1(testManager.create(
          [bytes32(0), bytes32(0)],
          [bytes32(0), bytes32(0), bytes32(0), bytes32(0), bytes32(0), bytes32(0), bytes32(0), bytes32(0)],
          uint(0),
          uint(100)
        ));
        //byte32[2]

        address[64] memory participants;
        participants = testAgreement.getParticipants();

        Assert.equal(participants[0], this, "Should have agreement creator");
        Assert.equal(testAgreement.getCreationBlock(), block.number, "Should be created in same block as test tx");
        Assert.equal(testAgreement.getCreationTimestamp(), block.timestamp, "Same timestamp as in test");
        Assert.equal(uint(testAgreement.getStatus()), uint(Agreement1_1.Status.New), "Should have \"New\" Status");

    }

}
