pragma solidity 0.4.24;

import "./StorageManagement.sol";


contract StorageClient {

  using StorageManagement for StorageManagement.StorageObjectRef;
  using StorageUtils for StorageUtils.SPointer;

  function getStoragePointer(bytes32 id) internal view returns(StorageUtils.SPointer memory) {
      StorageManagement.StorageObjectRef memory object;
      object.loadStorageObject();
      return object.storagePointersMapping.getStoragePointerMapping(object.currentContext);
  }

}
