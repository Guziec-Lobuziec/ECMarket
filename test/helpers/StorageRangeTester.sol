pragma solidity 0.4.24;

import "./StorageUtilsTester.sol";


contract StorageRangeTester is StorageUtilsTester {

  function position() internal pure returns(StorageUtils.SPointer memory) {
    return StorageUtils.SPointer({
      _start: 8,
      _length: 16,
      _at: 0
    });
  }

  function setByte32AtDifferentRange(uint p, bytes32 val) public {
      StorageUtils.SPointer memory ptr = StorageUtils.SPointer({
        _start: 32,
        _length: 16,
        _at: 0
      });
      bytes32[] memory tmp = new bytes32[](1);

      tmp[0] = val;
      ptr.setPositionAt(p);

      ptr.setSlots(tmp);
  }

  function getByte32AtDifferentRange(uint p) public view returns(bytes32) {
      StorageUtils.SPointer memory ptr = StorageUtils.SPointer({
        _start: 32,
        _length: 16,
        _at: 0
      });
      ptr.setPositionAt(p);

      return ptr.getSlots(1)[0];
  }

}
