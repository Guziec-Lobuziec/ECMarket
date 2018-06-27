pragma solidity 0.4.23;

import "./AgreementManager.sol";
import "./VirtualWallet.sol";


contract Agreement {
    enum Status { New, Running, Done}

    struct Participant {
        bool joined;
        bool accepted;
        bool creator;
        bool hasConcluded;
    }

    mapping(address => Participant) private participantsSet;
    address[] private participants;
    address[] private accepted;

    Status private currentStatus;

    uint private creationBlock;
    uint private creationTimestamp;
    AgreementManager private agreementManager;
    VirtualWallet private wallet;

    uint private price;
    uint private blocksToExpiration;
    bytes32[2] private name;
    bytes32[8] private description;

    constructor(
        address creator,
        address _wallet,
        uint _price,
        uint _blocksToExpiration,
        bytes32[2] _name,
        bytes32[8] _description
      ) public {
        agreementManager = AgreementManager(msg.sender);
        wallet = VirtualWallet(_wallet);

        name = _name;
        description = _description;
        blocksToExpiration = _blocksToExpiration;

        Participant memory toAdd = Participant({
            joined: true,
            accepted: true,
            creator: true,
            hasConcluded: false
        });

        participantsSet[creator] = toAdd;
        participants.push(creator);
        accepted.push(creator);

        creationBlock = block.number;
        creationTimestamp = block.timestamp;
        currentStatus = Status.New;

        price = _price;
    }

    function join() public {
        require(block.number < creationBlock + blocksToExpiration);
        require(getStatus() == Status.New);
        if (participantsSet[msg.sender].joined)
            return;

        wallet.transferFrom(msg.sender, this, getPrice());

        Participant memory toAdd = Participant({
            joined: true,
            accepted: false,
            creator: false,
            hasConcluded: false
        });
        participantsSet[msg.sender] = toAdd;
        participants.push(msg.sender);
    }

    function accept(address suplicant) public {
        require(block.number < creationBlock + blocksToExpiration);
        require(getStatus() == Status.New);
        require(participantsSet[msg.sender].creator);
        require(participantsSet[suplicant].joined);
        require(!participantsSet[suplicant].creator);

        wallet.transfer(participants[0], getPrice());

        participantsSet[suplicant].accepted = true;
        accepted.push(suplicant);
        currentStatus = Status.Running;
    }

    function conclude() public
    {
        require(block.number < creationBlock + blocksToExpiration);
        require(participantsSet[msg.sender].joined,"Address isn't part of agreement");
        require(participantsSet[msg.sender].accepted);
        require(!participantsSet[msg.sender].hasConcluded);
        require(getStatus() == Status.Running);

        participantsSet[msg.sender].hasConcluded = true;
        bool testIfAcceptedConcluded = true;
        for(uint i = 0; i<accepted.length; i++)
          testIfAcceptedConcluded =
            testIfAcceptedConcluded && participantsSet[accepted[i]].hasConcluded;
        if(testIfAcceptedConcluded)
          currentStatus = Status.Done;
    }

    function remove() public {
        require(participantsSet[msg.sender].creator);
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

    function getStatus() public view returns(Status) {
        return currentStatus;
    }

    function getName() public view returns(bytes32[2]) {
        return name;
    }

    function getDescription() public view returns(bytes32[8]) {
        return description;
    }

    function getBlocksToExpiration() public view returns(uint) {
        return blocksToExpiration;
    }

    function getPrice() public view returns(uint) {
        return price;
    }

    function getAPIJSON() public view returns(string) {
        return "[{\"name\": \"join\",\"type\": \"function\",\"inputs\": [],\"outputs\": []},{\"name\": \"accept\",\"type\": \"function\",\"inputs\": [{\"name\": \"suplicant\",\"type\": \"address[64]\"}],\"outputs\": []},{\"name\": \"getParticipants\",\"type\": \"function\",\"inputs\": [],\"outputs\": [{\"type\": \"address[64]\"}]},{\"name\": \"getCreationBlock\",\"type\": \"function\",\"inputs\": [],\"outputs\": [{\"type\": \"uint256\"}]},{\"name\": \"getCreationTimestamp\",\"type\": \"function\",\"inputs\": [],\"outputs\": [{\"type\": \"uint256\"}]},{\"name\": \"getStatus\",\"type\": \"function\",\"inputs\": [],\"outputs\": [{\"type\": \"Status\"}]},{\"name\": \"conclude\",\"type\": \"function\",\"inputs\": [],\"outputs\": []},{\"name\": \"remove\",\"type\": \"function\",\"inputs\": [],\"outputs\": []},{\"name\": \"getName\",\"type\": \"function\",\"inputs\": [],\"outputs\": [{\"type\": \"bytes32[2]\"}]},{\"name\": \"getDescription\",\"type\": \"function\",\"inputs\": [],\"outputs\": [{\"type\": \"bytes32[8]\"}]},{\"name\": \"getPrice\",\"type\": \"function\",\"inputs\":[],\"outputs\": [{\"type\": \"uint256\"}]}]";
    }

}
