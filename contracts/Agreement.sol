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

    uint private price;

    function Agreement(address creator, uint _price) public {
        agreementManager = AgreementManager(msg.sender);

        participantsSet[creator] = true;
        participants.push(creator);

        creationBlock = block.number;
        creationTimestamp = block.timestamp;
        currentStatus = Status.New;

        price = _price;
    }

    function join() public {
        require(block.number < creationBlock + 100);
        if (!participantsSet[msg.sender]) {
            participantsSet[msg.sender] = true;
            participants.push(msg.sender);
        }
    }

    function accept(address suplicant) public {
        require(block.number < creationBlock + 100);
        require(msg.sender == participants[0]);
        require(participantsSet[suplicant]);
        require(suplicant != participants[0]);
        currentStatus = Status.Running;
    }

    function conclude() public
    {
        require(block.number < creationBlock + 100);
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

    function getPrice() public view returns(uint) {
        return price;
    }

    function getStatus() public view returns(Status) {
        return currentStatus;
    }

    function setDoneFlag(bool flag) private
    {
        doneFlag = flag;
    }

}
