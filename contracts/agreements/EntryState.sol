pragma solidity 0.4.24;

import "./AgreementCommons.sol";
import "../machine/AbstractState.sol";
import "../utils/StorageClient.sol";


contract EntryState is StorageClient, AbstractState, AgreementCommons {

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

  function withdraw() public {
      require(getParticipantProperties(msg.sender).joined,"Address isn't part of agreement");
      require(!getParticipantProperties(msg.sender).accepted);
      require(!getParticipantProperties(msg.sender).creator);

      setParticipantProperties(
        msg.sender,
        Participant({
          joined: false,
          accepted: false,
          creator: false,
          hasConcluded: false
        })
      );

      removeParticipant(msg.sender);

      bool success = getTokenContract().approve(msg.sender, getPrice());
      require(success);

  }

  function getSharedStoragePointer() internal view returns(StorageUtils.SPointer memory) {
     return getStoragePointer(0x0);
  }

}
