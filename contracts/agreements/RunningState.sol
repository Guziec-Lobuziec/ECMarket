pragma solidity 0.4.24;

import "./StateCommons.sol";


contract RunningState is StateCommons {

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

  function getStatus() public view returns(Status) {
      return Status.Running;
  }

}
