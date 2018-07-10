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
        return manager.create(
          [bytes32(0), bytes32(0)],
          [bytes32(0), bytes32(0), bytes32(0), bytes32(0), bytes32(0), bytes32(0), bytes32(0), bytes32(0)],
          uint(0),
          uint(100)
        );
    }

    function joinAgreement(address agreement) public {
        Agreement1_1(agreement).join();
    }

    function acceptParticipant(address participant, address agreement) public {
        Agreement1_1(agreement).accept(participant);
    }

}
