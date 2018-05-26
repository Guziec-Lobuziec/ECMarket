pragma solidity 0.4.23;

import "../../contracts/AgreementManager.sol";


contract DummyParticipant {

    AgreementManager private manager;
    bool public hasFailed;

    function reset() public {
        hasFailed = false;
    }

    function setManager(address _manager) public {
        manager = AgreementManager(_manager);
    }

    function createAgreement() public returns(address) {
        return manager.create(uint(0));
    }

    function joinAgreement(address agreement) public {
        Agreement(agreement).join();
    }

    function acceptParticipant(address participant, address agreement) public {
        Agreement(agreement).accept(participant);
    }

}
