pragma solidity 0.4.23;

import "./AgreementManager.sol";


contract Agreement {
    enum Status { New, Running, Done}

    address[] private participants;
    mapping(address => bool) private participantsSet;

    Status private currentStatus;

    uint private creationBlock;
    uint private creationTimestamp;
    bool private doneFlag = false;
    AgreementManager private agreementManager;
    bytes32[2] private name;
    bytes32[8] private description;

    function Agreement(address creator, bytes32[2] _name, bytes32[8] _description) public {
        agreementManager = AgreementManager(msg.sender);
        name = _name;
        description = _description;

        participantsSet[creator] = true;
        participants.push(creator);

        creationBlock = block.number;
        creationTimestamp = block.timestamp;
        currentStatus = Status.New;
    }

    function join() public {
        if (!participantsSet[msg.sender]) {
            participantsSet[msg.sender] = true;
            participants.push(msg.sender);
        }
    }

    function accept(address suplicant) public {
        require(msg.sender == participants[0]);
        require(participantsSet[suplicant]);
        require(suplicant != participants[0]);
        currentStatus = Status.Running;
    }

    function getParticipants() public view returns(address[64]) { 
        address[64] memory page;
        for (uint i = 0; i < participants.length && i < 64; i++) {
            page[i] = participants[i];
        }
        return page;
    }

    function getCreationBlock() public view returns(uint) {
        return creationBlock;
    }

    function getCreationTimestamp() public view returns(uint) {
        return creationTimestamp;
    }

    function getStatus() public view returns(Status) {
        return currentStatus;
    }

    function conclude() public
    {
        require(participantsSet[msg.sender],"Address isn't part of agreement");
        setDoneFlag(true);
        currentStatus = Status.Done;
    }

    function remove() public {
        require(msg.sender == participants[0]);
        require(currentStatus != Status.Running);
        agreementManager.remove();
        selfdestruct(address(agreementManager));
    }

    function getName() public view returns(bytes32[2]) {
        return name;
    }

    function getDescription() public view returns(bytes32[8]) {
        return description;
    }

    function setDoneFlag(bool flag) private
    {
        doneFlag = flag;
    }

}
