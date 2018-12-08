pragma solidity 0.4.24;

import "./StateCommons.sol";


contract RemovingState is StateCommons {

  function remove() public isMachine {
      require(getParticipantProperties(msg.sender).creator);
      getAgreementManager().remove();

      selfdestruct(msg.sender);
  }

  function getStatus() public view returns(Status) {
      return Status.Done;
  }

}
