pragma solidity 0.4.24;

import "./AgreementCommons.sol";
import "../machine/AbstractState.sol";
import "../utils/StorageClient.sol";


contract RunningState is StorageClient, AbstractState, AgreementCommons {

  function getSharedStoragePointer() internal view returns(StorageUtils.SPointer memory) {
     return getStoragePointer(0x0);
  }

}
