pragma solidity 0.4.21;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

import "../contracts/AgreementManager.sol";


contract TestAgreement {

    function testAgreementDefaultProperties() {

        AgreementManager testManager = AgreementManager(DeployedAddresses.AgreementManager());

        Agreement testAgreement = Agreement(testManager.create());

        Assert.equal(testAgreement.getParticipants(), this, "Test should be creator and only participan");
        Assert.equal(testAgreement.getCreationBlock(), block.number, "Should be created in same block as test tx");
        Assert.equal(testAgreement.getCreationTimestamp(), block.timestamp, "Same timestamp as in test");
        Assert.equal(uint(testAgreement.getStatus()), uint(Agreement.Status.New), "Should have \"New\" Status");

    }

}
