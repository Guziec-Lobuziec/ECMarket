pragma solidity 0.4.24;

import "./RemovingState.sol";


contract EntryState is RemovingState {

  function join() public {
      require(block.number < getCreationBlock() + getBlocksToExpiration());
      if (getParticipantProperties(msg.sender).joined)
          return;

      Participant memory toAdd = Participant({
          joined: true,
          accepted: false,
          creator: false,
          hasConcluded: false
      });
      setParticipantProperties(msg.sender,toAdd);
      addParticipant(msg.sender);

      bool success = getTokenContract().transferFrom(msg.sender, this, getPrice());
      require(success);
  }

  function accept(address suplicant) public {
      require(block.number < getCreationBlock() + getBlocksToExpiration());
      require(getParticipantProperties(msg.sender).creator);
      require(getParticipantProperties(suplicant).joined);
      require(!getParticipantProperties(suplicant).creator);

      Participant memory toBeAccepted = getParticipantProperties(suplicant);
      toBeAccepted.accepted = true;
      setParticipantProperties(suplicant, toBeAccepted);

      addAcceptedParticipants(suplicant);

      StorageUtils.SPointer memory sharedStorage =
        getSharedStoragePointer();
      sharedStorage.setPositionAt(LOCATION_OF_PARTICIPANT_LIST);

      bool success = getTokenContract().approve(
        address(sharedStorage
          .mapSPointerTo(abi.encodePacked(
          sharedStorage
            .mapSPointerTo(abi.encodePacked(HEAD))
            .relativeMove(1)
            .mapSPointerTo(abi.encodePacked(NEXT))
            .getBytes32()
        )).getBytes32()),
        getPrice()
      );
      require(success);

      setMachineNextState(getMachineReachableStates()[0]);
  }

}
