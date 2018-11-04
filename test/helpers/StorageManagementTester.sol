pragma solidity 0.4.24;

import "../../contracts/machine/StorageManagement.sol";


contract StorageManagementTester {

    using StorageManagement for StorageManagement.StorageStart;
    using StorageManagement for StorageManagement.StorageObject;

    StorageManagement.StorageStart private start;
    bytes32 private zero;
    StorageManagement.StorageObject private object;


    function initStorageManagement() public {
        start.initialze(object);
    }

    function tryToGetStorageObject() public {
        StorageManagement.StorageObject memory obj;
        obj.loadStorageObject();
    }

    function getStorageObjectLocation() public view returns(uint) {
        return start._storageObjectLocation;
    }

    function getMagicNumberInStorageObject() public view returns(bytes32) {
        return object._magicNumber;
    }

    function setInvalidStorageObjectLocation() public {
        start._storageObjectLocation = 1;
    }



}
