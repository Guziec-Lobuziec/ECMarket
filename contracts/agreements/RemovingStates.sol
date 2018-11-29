pragma solidity 0.4.24;

import "./AgreementCommons.sol";
import "../machine/AbstractState.sol";
import "../utils/StorageClient.sol";


contract RunningState is StorageClient, AbstractState, AgreementCommons {

  function remove() public isMachine {
      require(getParticipantProperties(msg.sender).creator);
      agreementManager.remove();

      selfdestruct(address(agreementManager));
  }

}
