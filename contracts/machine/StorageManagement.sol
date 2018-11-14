pragma solidity 0.4.24;

import "./StorageUtils.sol";


library StorageManagement {

    //Magic number identifying valid StorageObject
    bytes32 constant private MAGIC = 0xcafefeed000011110000111100001111000011110000111100001111cafefeed;
    //StorageStart size without mappings and dynamic arrays
    uint256 constant private SSTART_SIZE = 1;
    //StorageObjectRef size without mappings and dynamic arrays
    uint256 constant private SOBJECT_REF_SIZE = 2;
    //StorageObject size
    uint256 constant private SOBJECT_SIZE = 3;

    using StorageUtils for StorageUtils.SPointer;

    struct StorageStart {
      uint256 _storageObjectLocation;
    }

    struct StorageObject {
      bytes32 _magicNumber;
      bytes32 _currentContext;
      mapping(bytes32 => StorageUtils.SPointer) _storagePointers;
    }

    struct StorageObjectRef {
      bytes32 currentContext;
      StorageUtils.SPointer storagePointersMapping;
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

    function setCurrentContext(
      StorageObject storage object,
      bytes32 context
    ) internal {
      object._currentContext = context;
    }

    function setSPointerFor(
      StorageObject storage object,
      bytes32 context,
      StorageUtils.SPointer pointer
    ) internal {
      object._storagePointers[context] = pointer;
    }

    function getCurrentContext(
      StorageObject storage object
    ) internal view returns(bytes32) {
      return object._currentContext;
    }

    function getSPointerFor(
      StorageObject storage object,
      bytes32 context
    ) internal view returns(StorageUtils.SPointer) {
      return object._storagePointers[context];
    }

    function getFreeStorageSlot() internal view returns(uint256) {
        StorageUtils.SPointer memory ptr = getStorageObjectSPointer();
        return ptr.getAbsolutSlotLocation() + SOBJECT_SIZE;
    }

    function getStorageObjectSPointer() internal view returns(StorageUtils.SPointer memory) {
        StorageUtils.SPointer memory ptr = StorageUtils.SPointer({
          _start: 0,
          _length: uint256(-1),
          _at: 0
        });

        //StorageStart._storageObjectLocation
        uint256 location = uint256(ptr.getSlots(SSTART_SIZE)[0]);
        assert(location != 0);
        ptr.setPositionAt(location);

        return ptr;
    }

    function loadStorageObject(StorageObjectRef memory object) internal view {

        StorageUtils.SPointer memory ptr = getStorageObjectSPointer();

        bytes32[] memory rawStorageObject = ptr.getSlots(SOBJECT_REF_SIZE);
        assert(rawStorageObject[0] == MAGIC);

        //currentContext
        object.currentContext = rawStorageObject[1];

        //starting slot for storagePointers mapping
        object.storagePointersMapping = StorageUtils.SPointer({
          _start: ptr.getAbsolutSlotLocation() + 2,
          _length: 1,
          _at: 0
        });


    }

}
