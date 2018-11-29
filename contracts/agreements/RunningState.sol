pragma solidity 0.4.24;

import "./AgreementCommons.sol";
import "../machine/AbstractState.sol";
import "../utils/StorageClient.sol";


contract RunningState is StorageClient, AbstractState, AgreementCommons {

  function getSharedStoragePointer() internal view returns(StorageUtils.SPointer memory) {
     return getStoragePointer(0x0);
  }

  function conclude() public {
      require(block.number < getCreationBlock() + getBlocksToExpiration());
      require(getParticipantProperties(msg.sender).joined,"Address isn't part of agreement");
      require(getParticipantProperties(msg.sender).accepted);
      require(!getParticipantProperties(msg.sender).hasConcluded);

      Participant memory concluder = getParticipantProperties(msg.sender);
      concluder.hasConcluded = true;
      setParticipantProperties(msg.sender, concluder);

      setMachineNextState(getMachineReachableStates()[0]);
  }

}
