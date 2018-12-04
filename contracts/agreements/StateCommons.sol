pragma solidity 0.4.24;

import "./AgreementCommons.sol";
import "../machine/AbstractState.sol";
import "../utils/StorageClient.sol";


contract StateCommons is StorageClient, AbstractState, AgreementCommons {

  modifier expirationSensitive {
    if(block.number < getCreationBlock() + getBlocksToExpiration()){
      setMachineNextState(getMachineReachableStates()[1]);
      return;
    }
    _;
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
