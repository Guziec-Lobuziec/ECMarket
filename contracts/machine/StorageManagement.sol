pragma solidity 0.4.24;


library StorageManagement {

    bytes32 constant private MAGIC = 0xcafefeed000011110000111100001111000011110000111100001111cafefeed;

    struct StorageStart {
      uint256 _storageObjectLocation;
    }

    struct StorageObject {
      bytes32 _magicNumber;
    }

    function initialze(
      StorageStart memory _start,
      StorageObject memory _object
    ) internal {

    }

    function loadStorageObject(StorageObject memory _object) internal {

    }

}
