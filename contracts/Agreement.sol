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
    address[] participants;
    address[] accepted;

    Status private currentStatus;

    uint private creationBlock;
    uint private creationTimestamp;
    AgreementManager private agreementManager;
    VirtualWallet private wallet;

    uint private price;

    constructor(address creator, address _wallet, uint _price) public {
        agreementManager = AgreementManager(msg.sender);
        wallet = VirtualWallet(_wallet);

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
        require(block.number < creationBlock + 100);
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
        require(block.number < creationBlock + 100);
        require(participantsSet[msg.sender].creator);
        require(participantsSet[suplicant].joined);
        require(!participantsSet[suplicant].creator);

        participantsSet[suplicant].accepted = true;
        accepted.push(suplicant);
        currentStatus = Status.Running;
    }

    function conclude() public
    {
        require(block.number < creationBlock + 100);
        require(participantsSet[msg.sender].joined,"Address isn't part of agreement");
        require(participantsSet[msg.sender].accepted);
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

    function getPrice() public view returns(uint) {
        return price;
    }

    function getStatus() public view returns(Status) {
        return currentStatus;
    }

}
