pragma solidity 0.4.24;

import "../utils/StorageUtils.sol";
import "../manager/IAgreementManager.sol";
import "../IEIP20.sol";


contract AgreementCommons {

  using StorageUtils for StorageUtils.SPointer;

  /* struct AddressList {
      address data;
      mapping(bool => uint) pointers;
  } */

  struct Participant {
      bool joined;
      bool accepted;
      bool creator;
      bool hasConcluded;
  }

  enum Status { New, Running, Done}

  uint constant internal SHARED_BASIC_TYPE_VALUES_SIZE = 7;

  uint constant internal LOCATION_OF_AGREEMENT_MANAGER = 0;
  uint constant internal LOCATION_OF_TOKEN_CONTRACT = 1;
  uint constant internal LOCATION_OF_CREATOR = 2;
  uint constant internal LOCATION_OF_CREATION_TIMESTAMP = 3;
  uint constant internal LOCATION_OF_CREATION_BLOCK = 4;
  uint constant internal LOCATION_OF_BLOCKS_TO_EXPIRATION = 5;
  uint constant internal LOCATION_OF_PRICE = 6;
  uint constant internal LOCATION_OF_PARTICIPANT_LIST = 7;
  uint constant internal LOCATION_OF_PARTICIPANT_PROP_SET = 8;
  uint constant internal LOCATION_OF_ACCEPTED_ARRAY = 9;
  uint constant internal ADDRESS_LIST_ELEMENT_SIZE = 2;

  bytes32 constant internal HEAD = 0x0;
  bool constant internal NEXT = true;
  bool constant internal PREV = false;

  bytes32[] internal name;
  bytes32[] internal description;

  function getSharedStoragePointer() internal view returns(StorageUtils.SPointer memory);

  function getParticipants() public view returns(address[]) {
      StorageUtils.SPointer memory sharedStorage =
        getSharedStoragePointer();
      sharedStorage.setPositionAt(LOCATION_OF_PARTICIPANT_LIST);

      address[] memory page = new address[](64);
      bytes32 current = HEAD;
      uint i = 0;
      while (
        (
          sharedStorage
            .mapSPointerTo(abi.encodePacked(current))
            .relativeMove(1)
            .mapSPointerTo(abi.encodePacked(NEXT))
            .getBytes32() != HEAD
        ) && i<64
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
        getSharedStoragePointer();
      sharedStorage.setPositionAt(LOCATION_OF_CREATION_BLOCK);
      return uint(sharedStorage.getBytes32());
  }

  function getCreationTimestamp() public view returns(uint) {
      StorageUtils.SPointer memory sharedStorage =
        getSharedStoragePointer();
      sharedStorage.setPositionAt(LOCATION_OF_CREATION_TIMESTAMP);
      return uint(sharedStorage.getBytes32());
  }

  function getName() public view returns(bytes32[]) {
      bytes32[] memory ret = new bytes32[](name.length);
      for(uint i = 0; i<name.length; i++)
        ret[i] = name[i];
      return ret;
  }

  function getDescription() public view returns(bytes32[]) {
      bytes32[] memory ret = new bytes32[](description.length);
      for(uint i = 0; i<description.length; i++)
        ret[i] = description[i];
      return ret;
  }

  function getBlocksToExpiration() public view returns(uint) {
      StorageUtils.SPointer memory sharedStorage =
        getSharedStoragePointer();
      sharedStorage.setPositionAt(LOCATION_OF_BLOCKS_TO_EXPIRATION);
      return uint(sharedStorage.getBytes32());
  }

  function getPrice() public view returns(uint) {
      StorageUtils.SPointer memory sharedStorage =
        getSharedStoragePointer();
      sharedStorage.setPositionAt(LOCATION_OF_PRICE);
      return uint(sharedStorage.getBytes32());
  }

  function getAgreementManager() internal view returns(IAgreementManager) {
      StorageUtils.SPointer memory sharedStorage =
        getSharedStoragePointer();
      sharedStorage.setPositionAt(LOCATION_OF_AGREEMENT_MANAGER);
      return IAgreementManager(address(sharedStorage.getBytes32()));
  }

  function getTokenContract() internal view returns(IEIP20) {
      StorageUtils.SPointer memory sharedStorage =
        getSharedStoragePointer();
      sharedStorage.setPositionAt(LOCATION_OF_TOKEN_CONTRACT);
      return IEIP20(address(sharedStorage.getBytes32()));
  }

  function getParticipantProperties(address participant) internal view returns(Participant memory) {
      StorageUtils.SPointer memory sharedStorage =
        getSharedStoragePointer();
      sharedStorage.setPositionAt(LOCATION_OF_PARTICIPANT_PROP_SET);

      bytes32 tmp = sharedStorage.mapSPointerTo(abi.encodePacked(participant)).getBytes32();

      return Participant({
        joined: tmp[0] == 0x01,
        accepted: tmp[1] == 0x01,
        creator: tmp[2] == 0x01,
        hasConcluded: tmp[3] == 0x01
      });
  }

  function getAcceptedParticipant(uint index) internal view returns(address) {

      StorageUtils.SPointer memory sharedStorage =
        getSharedStoragePointer();
      sharedStorage.setPositionAt(LOCATION_OF_ACCEPTED_ARRAY);

      require(index < uint(sharedStorage.getBytes32()));

      return address(sharedStorage.mapSPointerTo().relativeMove(int(index)).getBytes32());
  }

  function setParticipantProperties(address key ,Participant props) internal{
      StorageUtils.SPointer memory sharedStorage =
        getSharedStoragePointer();
      sharedStorage.setPositionAt(LOCATION_OF_PARTICIPANT_PROP_SET);

      bytes32 composed =
      (props.joined ? bytes32(0x01) : bytes32(0x00))<<248 |
      (props.accepted ? bytes32(0x01) : bytes32(0x00))<<240 |
      (props.creator ? bytes32(0x01) : bytes32(0x00))<<232 |
      (props.hasConcluded ? bytes32(0x01) : bytes32(0x00))<<224;

      sharedStorage.mapSPointerTo(abi.encodePacked(key)).setBytes32(composed);
  }

  function addAcceptedParticipants(address participant) internal {
      StorageUtils.SPointer memory sharedStorage =
        getSharedStoragePointer();
      sharedStorage.setPositionAt(LOCATION_OF_ACCEPTED_ARRAY);

      uint length = uint(sharedStorage.getBytes32());

      sharedStorage.mapSPointerTo().relativeMove(int(length)).setBytes32(bytes32(participant));

      sharedStorage.setBytes32(bytes32(length+1));
  }

  function addParticipant(address participant) internal {

      StorageUtils.SPointer memory pointer =
        getSharedStoragePointer();
      pointer.setPositionAt(LOCATION_OF_PARTICIPANT_LIST);

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

  function removeParticipant(address participant) internal {

      StorageUtils.SPointer memory sharedStorage =
        getSharedStoragePointer();
      sharedStorage.setPositionAt(LOCATION_OF_PARTICIPANT_LIST);

      bytes32 current = HEAD;
      //Insecure loop!
      while (
        (sharedStorage
          .mapSPointerTo(abi.encodePacked(current))
          .relativeMove(1)
          .mapSPointerTo(abi.encodePacked(NEXT))
          .getBytes32() != HEAD)
        ) {
          current = sharedStorage
            .mapSPointerTo(abi.encodePacked(current))
            .relativeMove(1)
            .mapSPointerTo(abi.encodePacked(NEXT))
            .getBytes32();

          if (
            sharedStorage
            .mapSPointerTo(abi.encodePacked(current)).getBytes32() == bytes32(participant)
            ) {

              sharedStorage
                .mapSPointerTo(
                  abi.encodePacked(
                    sharedStorage
                      .mapSPointerTo(abi.encodePacked(current))
                      .relativeMove(1)
                      .mapSPointerTo(abi.encodePacked(PREV))
                      .getBytes32()
                    )
                )
                .relativeMove(1)
                .mapSPointerTo(abi.encodePacked(NEXT))
                .setBytes32(
                  sharedStorage
                    .mapSPointerTo(abi.encodePacked(current))
                    .relativeMove(1)
                    .mapSPointerTo(abi.encodePacked(NEXT))
                    .getBytes32()
                );

                sharedStorage
                  .mapSPointerTo(
                    abi.encodePacked(
                      sharedStorage
                        .mapSPointerTo(abi.encodePacked(current))
                        .relativeMove(1)
                        .mapSPointerTo(abi.encodePacked(NEXT))
                        .getBytes32()
                      )
                  )
                  .relativeMove(1)
                  .mapSPointerTo(abi.encodePacked(PREV))
                  .setBytes32(
                    sharedStorage
                      .mapSPointerTo(abi.encodePacked(current))
                      .relativeMove(1)
                      .mapSPointerTo(abi.encodePacked(PREV))
                      .getBytes32()
                  );

              /* list[list[current].pointers[PREV]].pointers[NEXT]
              = list[current].pointers[NEXT]; */

              /* list[list[current].pointers[NEXT]].pointers[PREV]
              = list[current].pointers[PREV]; */

              sharedStorage
                .mapSPointerTo(abi.encodePacked(current))
                .relativeMove(1)
                .mapSPointerTo(abi.encodePacked(NEXT))
                .setBytes32(0x0);
              sharedStorage
                .mapSPointerTo(abi.encodePacked(current))
                .relativeMove(1)
                .mapSPointerTo(abi.encodePacked(PREV))
                .setBytes32(0x0);
              sharedStorage
                .mapSPointerTo(abi.encodePacked(current))
                .setBytes32(0x0);

              /* delete list[current].pointers[NEXT];
              delete list[current].pointers[PREV];
              delete list[current]; */

              break;
          }
      }

  }

}
