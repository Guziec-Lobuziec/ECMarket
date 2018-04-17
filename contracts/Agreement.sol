pragma solidity 0.4.21;


contract Agreement {
    enum Status { New }
    address private creator;
    uint private creationBlock;
    uint private creationTimestamp;

    function Agreement(address _creator) public {
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

}
