pragma solidity 0.4.24;

import "../machine/StateMachine.sol";
import "../utils/StorageController.sol";
import "./AgreementCommons.sol";


contract Agreement is StorageController, StateMachine, AgreementCommons {

    event _debug(uint start, uint length, uint at);

    using StorageManagement for StorageManagement.StorageObject;
    using StorageUtils for StorageUtils.SPointer;

    uint constant public NAME_SIZE = 2;
    uint constant public DESCRIPTION_SIZE = 8;

    uint constant private SHARED_STORAGE_SIZE = 256;

    /* mapping (uint => AddressList) private list;

    mapping(address => Participant) private participantsSet;
    address[] private accepted;*/
    bool private isInitialzed;

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
        getSharedStoragePointer();

      bytes32[] memory valuesToSave = new bytes32[](SHARED_BASIC_TYPE_VALUES_SIZE);
      valuesToSave[LOCATION_OF_AGREEMENT_MANAGER] = bytes32(agreementManager);
      valuesToSave[LOCATION_OF_TOKEN_CONTRACT] = bytes32(tokenContract);
      valuesToSave[LOCATION_OF_CREATOR] = bytes32(creator);

      valuesToSave[LOCATION_OF_CREATION_TIMESTAMP] = bytes32(block.timestamp);
      valuesToSave[LOCATION_OF_CREATION_BLOCK] = bytes32(block.number);
      valuesToSave[LOCATION_OF_BLOCKS_TO_EXPIRATION] = bytes32(blocksToExpiration);

      valuesToSave[LOCATION_OF_PRICE] = bytes32(price);
      //7 - AddressList
      //8 - acceptedMapping
      //9 - acceptArray

      sharedStorage.setSlots(valuesToSave);
      addParticipant(creator);

      Participant memory toAdd = Participant({
          joined: true,
          accepted: true,
          creator: true,
          hasConcluded: false
      });

      setParticipantProperties(creator,toAdd);
      addAcceptedParticipants(creator);

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

    function getSharedStoragePointer() internal view returns(StorageUtils.SPointer memory) {
      return object.getSPointerFor(object.getCurrentContext());
    }

}
