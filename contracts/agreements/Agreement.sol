pragma solidity 0.4.24;

import "../manager/IAgreementManager.sol";
import "../IEIP20.sol";


contract Agreement {

    uint constant private HEAD = 0;
    bool constant private NEXT = true;
    bool constant private PREV = false;

    enum Status { New, Running, Done}

    struct Participant {
        bool joined;
        bool accepted;
        bool creator;
        bool hasConcluded;
    }

    struct AddressList {
        address data;
        mapping(bool => uint) pointers;
    }

    mapping (uint => AddressList) private list;

    mapping(address => Participant) private participantsSet;
    address[] private accepted;

    Status private currentStatus;

    uint private creationBlock;
    uint private creationTimestamp;
    IAgreementManager private agreementManager;
    IEIP20 private tokenContract;

    uint private price;
    uint private blocksToExpiration;
    bytes32[2] private name;
    bytes32[8] private description;

    constructor(
        address _agreementManager,
        address _tokenContract,
        address creator,
        uint _price,
        uint _blocksToExpiration,
        bytes32[2] _name,
        bytes32[8] _description
      ) public {
        agreementManager = IAgreementManager(_agreementManager);
        tokenContract = IEIP20(_tokenContract);

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
        addParticipant(creator);
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

        Participant memory toAdd = Participant({
            joined: true,
            accepted: false,
            creator: false,
            hasConcluded: false
        });
        participantsSet[msg.sender] = toAdd;
        addParticipant(msg.sender);

        bool success = tokenContract.transferFrom(msg.sender, this, getPrice());
        require(success);
    }

    function accept(address suplicant) public {
        require(block.number < creationBlock + blocksToExpiration);
        require(getStatus() == Status.New);
        require(participantsSet[msg.sender].creator);
        require(participantsSet[suplicant].joined);
        require(!participantsSet[suplicant].creator);

        participantsSet[suplicant].accepted = true;
        accepted.push(suplicant);
        currentStatus = Status.Running;

        bool success = tokenContract.approve(list[list[HEAD].pointers[NEXT]].data, getPrice());
        require(success);
    }

    function conclude() public {
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

    function withdraw() public {
        require(participantsSet[msg.sender].joined,"Address isn't part of agreement");
        require(!participantsSet[msg.sender].accepted);
        require(!participantsSet[msg.sender].creator);

        participantsSet[msg.sender] = Participant({
            joined: false,
            accepted: false,
            creator: false,
            hasConcluded: false
        });

        address toBeRemoved = msg.sender;
        uint current = HEAD;
        //Insecure loop!
        while ((list[current].pointers[NEXT] != HEAD)) {
            current = list[current].pointers[NEXT];
            if (list[current].data == toBeRemoved) {

                list[list[current].pointers[PREV]].pointers[NEXT]
                = list[current].pointers[NEXT];

                list[list[current].pointers[NEXT]].pointers[PREV]
                = list[current].pointers[PREV];

                delete list[current].pointers[NEXT];
                delete list[current].pointers[PREV];
                delete list[current];

                break;
            }
        }

        bool success = tokenContract.approve(msg.sender, getPrice());
        require(success);
    }

    function remove() public {
        require(participantsSet[msg.sender].creator);
        require(currentStatus != Status.Running);
        agreementManager.remove();

        selfdestruct(address(agreementManager));
    }

    function getParticipants() public view returns(address[64]) {
        address[64] memory page;
        uint current = HEAD;
        uint i = 0;
        while ((list[current].pointers[NEXT] != HEAD) && (i < 64)) {
            current = list[current].pointers[NEXT];
            page[i] = list[current].data;
            i++;
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

    function addParticipant(address _participant) private {
      uint previous = list[HEAD].pointers[PREV];
      uint newNode = uint(keccak256(previous, block.number));

      list[previous].pointers[NEXT] = newNode;
      list[HEAD].pointers[PREV] = newNode;

      list[newNode].data = _participant;

      list[newNode].pointers[NEXT] = HEAD;
      list[newNode].pointers[PREV] = previous;
    }

}
