pragma solidity 0.4.21;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

import "../contracts/AgreementManager.sol";


contract TestAgreementManager {

    function testNoAgreementsInSystem() {

        AgreementManager testManager = AgreementManager(DeployedAddresses.AgreementManager());

        address[] memory expected = new address[];

        Assert.equal(testManager.search(), expected, "When no agreements are present return empty array");

    }

    function testAgreementCreation() {

        AgreementManager testManager = AgreementManager(DeployedAddresses.AgreementManager());

        address newAgreement = testManager.create();

        Assert.equal(testManager.search(), [newAgreement], "New agreement should be added");

    }

}
