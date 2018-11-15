pragma solidity 0.4.24;

import "../manager/IAgreementManager.sol";
import "../IEIP20.sol";
import "../machine/StateMachine.sol";
import "../utils/StorageController.sol";


contract Agreement is StorageController, StateMachine {

    event _debug(uint start, uint length, uint at);

    using StorageManagement for StorageManagement.StorageObject;
    using StorageUtils for StorageUtils.SPointer;

    uint constant public NAME_SIZE = 2;
    uint constant public DESCRIPTION_SIZE = 8;

    uint constant private SHARED_STORAGE_SIZE = 256;
    uint constant private SHARED_VALUES_SIZE = 7;
    uint constant private ADDRESS_LIST_ELEMENT_SIZE = 2;

    bytes32 constant private HEAD = 0x0;
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

    /* mapping (uint => AddressList) private list;

    mapping(address => Participant) private participantsSet;
    address[] private accepted;

    uint private creationBlock;
    uint private creationTimestamp;
    IAgreementManager private agreementManager;
    IEIP20 private tokenContract;

    uint private price;
    uint private blocksToExpiration; */
    bool private isInitialzed;
    bytes32[] private name;
    bytes32[] private description;

    StorageManagement.StorageObject object;

    constructor(
        address[] mutators,
        bytes32[] states,
        uint[] lengthOfReachableStates,
        bytes32[] arrayOfArraysOfReachableStates,
        bytes32 entryState
      ) StateMachine(
        mutators,
        states,
        lengthOfReachableStates,
        arrayOfArraysOfReachableStates,
        entryState
      ) public {

        start.initialze(object);

        object.setSPointerFor(
          object.getCurrentContext(),
          StorageUtils.SPointer({
            _start: StorageManagement.getFreeStorageSlot(),
            _length: SHARED_STORAGE_SIZE,
            _at: 0
          })
        );

    }

    function init(
      address agreementManager,
      address tokenContract,
      address creator,
      uint price,
      uint blocksToExpiration,
      bytes32[] _name,
      bytes32[] _description
    ) external {

      require(!isInitialzed);
      isInitialzed = true;

      for(uint i = 0; i<_name.length; i++) {
        name.push(_name[i]);
      }

      for(uint j = 0; j<_description.length; j++) {
        description.push(_description[j]);
      }

      StorageUtils.SPointer memory sharedStorage =
        object.getSPointerFor(object.getCurrentContext());

      bytes32[] memory valuesToSave = new bytes32[](SHARED_VALUES_SIZE);
      valuesToSave[0] = bytes32(agreementManager);
      valuesToSave[1] = bytes32(tokenContract);
      valuesToSave[2] = bytes32(creator);

      valuesToSave[3] = bytes32(block.timestamp);
      valuesToSave[4] = bytes32(block.number);
      valuesToSave[5] = bytes32(blocksToExpiration);

      valuesToSave[6] = bytes32(price);
      //7 - AddressList
      //8 - acceptedMapping
      //9 - acceptArray

      sharedStorage.setSlots(valuesToSave);

      sharedStorage.setPositionAt(SHARED_VALUES_SIZE);
      addParticipant(sharedStorage,creator);

      sharedStorage.setPositionAt(SHARED_VALUES_SIZE+1);

      /* Participant memory toAdd = Participant({
          joined: true,
          accepted: true,
          creator: true,
          hasConcluded: false
      });

      participantsSet[creator] = toAdd;
      accepted.push(creator); */

    }

    /* function join() public {
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
    } */

    function getParticipants() public view returns(address[64]) {
        StorageUtils.SPointer memory sharedStorage =
          object.getSPointerFor(object.getCurrentContext());
        sharedStorage.setPositionAt(SHARED_VALUES_SIZE);

        address[64] memory page;
        bytes32 current = HEAD;
        uint i = 0;
        while (
          (
            sharedStorage
              .mapSPointerTo(abi.encodePacked(current))
              .relativeMove(1)
              .mapSPointerTo(abi.encodePacked(NEXT))
              .getBytes32() != HEAD
          ) && (i < 64)
        ) {
            current = sharedStorage
              .mapSPointerTo(abi.encodePacked(current))
              .relativeMove(1)
              .mapSPointerTo(abi.encodePacked(NEXT))
              .getBytes32();

            page[i] = address(sharedStorage
              .mapSPointerTo(abi.encodePacked(current))
              .getBytes32());
            i++;
        }
        return page;
    }

    function getCreationBlock() public view returns(uint) {
        StorageUtils.SPointer memory sharedStorage =
          object.getSPointerFor(object.getCurrentContext());
        sharedStorage.setPositionAt(4);
        return uint(sharedStorage.getBytes32());
    }

    function getCreationTimestamp() public view returns(uint) {
        StorageUtils.SPointer memory sharedStorage =
          object.getSPointerFor(object.getCurrentContext());
        sharedStorage.setPositionAt(3);
        return uint(sharedStorage.getBytes32());
    }

    function getStatus() public view returns(Status) {
        return Status.New;
    }

    function getName() public view returns(bytes32[]) {
        bytes32[] memory ret = new bytes32[](NAME_SIZE);
        for(uint i = 0; i<NAME_SIZE; i++)
          ret[i] = name[i];
        return ret;
    }

    function getDescription() public view returns(bytes32[]) {
        bytes32[] memory ret = new bytes32[](DESCRIPTION_SIZE);
        for(uint i = 0; i<DESCRIPTION_SIZE; i++)
          ret[i] = description[i];
        return ret;
    }

    function getBlocksToExpiration() public view returns(uint) {
        StorageUtils.SPointer memory sharedStorage =
          object.getSPointerFor(object.getCurrentContext());
        sharedStorage.setPositionAt(5);
        return uint(sharedStorage.getBytes32());
    }

    function getPrice() public view returns(uint) {
        StorageUtils.SPointer memory sharedStorage =
          object.getSPointerFor(object.getCurrentContext());
        sharedStorage.setPositionAt(6);
        return uint(sharedStorage.getBytes32());
    }

    function getAPIJSON() public view returns(string) {
        return "[{\"name\": \"join\",\"type\": \"function\",\"inputs\": [],\"outputs\": []},{\"name\": \"accept\",\"type\": \"function\",\"inputs\": [{\"name\": \"suplicant\",\"type\": \"address[64]\"}],\"outputs\": []},{\"name\": \"getParticipants\",\"type\": \"function\",\"inputs\": [],\"outputs\": [{\"type\": \"address[64]\"}]},{\"name\": \"getCreationBlock\",\"type\": \"function\",\"inputs\": [],\"outputs\": [{\"type\": \"uint256\"}]},{\"name\": \"getCreationTimestamp\",\"type\": \"function\",\"inputs\": [],\"outputs\": [{\"type\": \"uint256\"}]},{\"name\": \"getStatus\",\"type\": \"function\",\"inputs\": [],\"outputs\": [{\"type\": \"Status\"}]},{\"name\": \"conclude\",\"type\": \"function\",\"inputs\": [],\"outputs\": []},{\"name\": \"remove\",\"type\": \"function\",\"inputs\": [],\"outputs\": []},{\"name\": \"getName\",\"type\": \"function\",\"inputs\": [],\"outputs\": [{\"type\": \"bytes32[2]\"}]},{\"name\": \"getDescription\",\"type\": \"function\",\"inputs\": [],\"outputs\": [{\"type\": \"bytes32[8]\"}]},{\"name\": \"getPrice\",\"type\": \"function\",\"inputs\":[],\"outputs\": [{\"type\": \"uint256\"}]}]";
    }

    function addParticipant(StorageUtils.SPointer memory pointer, address participant) private {

        bytes32 previous = pointer
            .mapSPointerTo(abi.encodePacked(HEAD))
            .relativeMove(1)
            .mapSPointerTo(abi.encodePacked(PREV))
            .getBytes32();

        bytes32 newNode = keccak256(abi.encodePacked(previous, block.number));

        pointer
          .mapSPointerTo(abi.encodePacked(previous))
          .relativeMove(1)
          .mapSPointerTo(abi.encodePacked(NEXT))
          .setBytes32(newNode);

        pointer
          .mapSPointerTo(abi.encodePacked(HEAD))
          .relativeMove(1)
          .mapSPointerTo(abi.encodePacked(PREV))
          .setBytes32(newNode);

        pointer
          .mapSPointerTo(abi.encodePacked(newNode))
          .setBytes32(bytes32(participant));

        pointer
          .mapSPointerTo(abi.encodePacked(newNode))
          .relativeMove(1)
          .mapSPointerTo(abi.encodePacked(NEXT))
          .setBytes32(HEAD);

        pointer
          .mapSPointerTo(abi.encodePacked(newNode))
          .relativeMove(1)
          .mapSPointerTo(abi.encodePacked(PREV))
          .setBytes32(previous);
    }

}
