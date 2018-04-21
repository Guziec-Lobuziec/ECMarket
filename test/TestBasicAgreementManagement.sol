pragma solidity 0.4.21;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

import "../contracts/AgreementManager.sol";


contract TestBasicAgreementManagement {

    function testAgreementRemoval() {
        AgreementManager testManager = AgreementManager(DeployedAddresses.AgreementManager());

        address[64] memory before = testManager.search();

        for (uint j = 0; j < before.length; j++) {
            Assert.equal(before[j], 0, "expected 0 before");
            
        }

        Agreement testAgreement = Agreement(testManager.create());

        Assert.notEqual(testAgreement, 0, "Agreement doesn't exist");

        testAgreement.remove();

        address[64] memory expected = testManager.search();

        for (uint i = 0; i < expected.length; i++) {
            Assert.equal(expected[i], 0, "expected 0");
        }

    }

}