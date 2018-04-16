pragma solidity 0.4.21;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

import "../contracts/AgreementManager.sol";


contract TestAgreementManager {

    function testNoAgreementsInSystem() {

        AgreementManager testManager = AgreementManager(DeployedAddresses.AgreementManager());

        Assert.equal(testManager.search(), 0, "When no agreements are present return 0");

    }

}
