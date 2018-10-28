pragma solidity 0.4.24;

import "../../contracts/machine/StorageUtils.sol";


contract StorageUtilsTester {

    using StorageUtils for StorageUtils.Position;

    function position() internal pure returns(StorageUtils.Position memory) {
      return StorageUtils.Position({
        _start: 0,
        _length: uint(-1),
        _at: 0
      });
    }

    function setUintAt(uint at ,uint val) public {

      StorageUtils.Position memory pos = position();
      pos.setPositionAt(at);

      bytes32[] memory slots = new bytes32[](1);
      slots[0] = bytes32(val);

      pos.setSlots(slots);

    }

    function getUintAt(uint at) public view returns (uint) {

      StorageUtils.Position memory pos = position();
      pos.setPositionAt(at);

      bytes32[] memory slots = pos.getSlots(1);

      return uint(slots[0]);

    }

    function setByte32At(uint p, bytes32 val) public {
        StorageUtils.Position memory ptr = position();
        bytes32[] memory tmp = new bytes32[](1);

        tmp[0] = val;
        ptr.setPositionAt(p);

        ptr.setSlots(tmp);
    }

    function getByte32At(uint p) public view returns(bytes32) {
        StorageUtils.Position memory ptr = position();
        ptr.setPositionAt(p);

        return ptr.getSlots(1)[0];
    }

    function setManytUintAt(uint at, uint[] vals) public {

      StorageUtils.Position memory pos = position();
      pos.setPositionAt(at);

      bytes32[] memory slots = new bytes32[](vals.length);
      for(uint i = 0; i<vals.length; i++) {
        slots[i] = bytes32(vals[i]);
      }

      pos.setSlots(slots);

    }

    function getManyUintAt(uint at, uint size) public view returns(uint[]) {

      StorageUtils.Position memory pos = position();
      pos.setPositionAt(at);

      bytes32[] memory slots = pos.getSlots(size);
      uint[] memory ret = new uint[](size);
      for(uint i = 0; i<size; i++) {
        ret[i] = uint(slots[i]);
      }

      return ret;

    }

    function setBytesAt(uint at, bytes vals) public {

      StorageUtils.Position memory pos = position();
      pos.setPositionAt(at);

      pos.setBytes(vals);

    }

    function getBytesAt(uint at) public view returns(bytes) {

      StorageUtils.Position memory pos = position();
      pos.setPositionAt(at);

      return pos.getBytes();

    }

}
