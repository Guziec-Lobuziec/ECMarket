pragma solidity 0.4.23;

import "./AgreementManager.sol";


contract Agreement {
    enum Status { New }
    address private creator;
    uint private creationBlock;
    uint private creationTimestamp;
    AgreementManager private agreementManager;

    function Agreement(address _creator) public {
        agreementManager = AgreementManager(msg.sender);
        creator = _creator;
        creationBlock = block.number;
        creationTimestamp = block.timestamp;
    }

    function getParticipants() public view returns(address) {
        return creator;
    }

    function getCreationBlock() public view returns(uint) {
        return creationBlock;
    }

    function getCreationTimestamp() public view returns(uint) {
        return creationTimestamp;
    }

    function getStatus() public view returns(Status) {
        return Status.New;
    }

    function remove() public {
        require(msg.sender == creator);
        agreementManager.remove();
        selfdestruct(address(agreementManager));
    }

}
