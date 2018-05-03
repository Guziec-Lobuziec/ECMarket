pragma solidity 0.4.23;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

import "../contracts/AgreementManager.sol";


contract DummyParticipant {

    AgreementManager private manager;

    function setManager(address _manager) public {
        manager = AgreementManager(_manager);
    }

    function createAgreement() public returns(address) {
        return manager.create();
    }

    function joinAgreement(address agreement) public {
        Agreement(agreement).join();
    }

    function acceptParticipant(address participant, address agreement) public {
        Agreement(agreement).accept(participant);
    }

}


contract TestAgreementBasicAccept {

    AgreementManager testManager;
    DummyParticipant creator;
    DummyParticipant suplicant;
    Agreement agreement;

    function beforeAll() {
        testManager = AgreementManager(DeployedAddresses.AgreementManager());
        creator = new DummyParticipant();
        creator.setManager(address(testManager));
        suplicant = new DummyParticipant();
        agreement = Agreement(creator.createAgreement());
    }

    function testAcceptingParticipant() {
        suplicant.joinAgreement(address(agreement));
        creator.acceptParticipant(address(suplicant), address(agreement));
        Assert.equal(
            uint(agreement.getStatus()),
            uint(Agreement.Status.Running),
            "Should have \"Running\" Status"
        );
    }

}
