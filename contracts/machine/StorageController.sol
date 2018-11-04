pragma solidity 0.4.24;

import "./StorageManagement.sol";


contract StorageController {

  using StorageManagement for StorageManagement.StorageStart;
  using StorageManagement for StorageManagement.StorageObject;

  //must occupy 0 slot in contract
  StorageManagement.StorageStart private start;

}
