pragma solidity 0.4.21;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

import "../contracts/AgreementManager.sol";


contract TestAgreementManager {

    function testNoAgreementsInSystem() {

        AgreementManager testManager = AgreementManager(DeployedAddresses.AgreementManager());

        address[64] memory got = testManager.search();

        for (uint i = 0; i < got.length; i++) {
            Assert.equal(got[i], 0, "All should be zero");

        }

    }

    function testAgreementCreation() {

        AgreementManager testManager = AgreementManager(DeployedAddresses.AgreementManager());

        address[64] memory expected;
        expected[0] = testManager.create();

        address[64] memory got = testManager.search();

        Assert.notEqual(expected[0], 0, "Should be created");

        Assert.equal(got.length, expected.length, "Should have the same size");

        for (uint i = 0; i < got.length; i++) {
            Assert.equal(got[i], expected[i], "New agreement should be added");
        }

    }

}
