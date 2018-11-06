pragma solidity 0.4.24;

import "./StorageManagement.sol";


contract StorageController {

  using StorageManagement for StorageManagement.StorageStart;

  //must occupy 0 slot in contract
  StorageManagement.StorageStart internal start;

}
