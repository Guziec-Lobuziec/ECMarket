pragma solidity 0.4.24;

import "./StorageUtils.sol";


library StorageManagement {

    bytes32 constant private MAGIC = 0xcafefeed000011110000111100001111000011110000111100001111cafefeed;
    uint256 constant private SSTART_SIZE = 1;
    uint256 constant private SOBJECT_SIZE = 1;

    using StorageUtils for StorageUtils.SPointer;

    struct StorageStart {
      uint256 _storageObjectLocation;
    }

    struct StorageObject {
      bytes32 _magicNumber;
    }

    function initialze(
      StorageStart storage start,
      StorageObject storage _object
    ) internal {

        uint256 _location;
        assembly {
          _location := _object_slot
        }
        start._storageObjectLocation = _location;
        _object._magicNumber = MAGIC;
    }

    function loadStorageObject(StorageObject memory object) internal {

        StorageUtils.SPointer memory ptr = StorageUtils.SPointer({
          _start: 0,
          _length: uint256(-1),
          _at: 0
        });

        //StorageStart._storageObjectLocation
        uint256 location = uint256(ptr.getSlots(SSTART_SIZE)[0]);
        assert(location != 0);
        ptr.setPositionAt(location);

        bytes32[] memory rawStorageObject = ptr.getSlots(SOBJECT_SIZE);
        object._magicNumber = rawStorageObject[0];
        assert(object._magicNumber == MAGIC);


    }

}
