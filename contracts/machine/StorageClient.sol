pragma solidity 0.4.24;

import "./StorageManagement.sol";


contract StorageClient {

  using StorageManagement for StorageManagement.StorageObject;

  function getStoragePointer(bytes32 id) internal view returns(StorageUtils.SPointer memory) {
      StorageManagement.StorageObject memory obj;
      obj.loadStorageObject();
      return obj.storagePointers[obj.currentContext];
  }

}
