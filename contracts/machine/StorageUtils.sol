pragma solidity 0.4.24;


library StorageUtils {

    struct Position{
      uint _at;
    }

    function setSlots(Position memory position, bytes32[] memory _value) internal {
      uint256 _valueSize = _value.length;
      uint256 _position = position._at;

      assembly {
        //fast, unsafe memory to storage copy
        for{ let _i := 0 } lt(_i, _valueSize) { _i := add(_i, 1) } {
          sstore(add(_position, _i), mload(add(add(_value, 0x20), mul(_i, 0x20))))
        }
      }

  }

  function getSlots(
    Position memory position,
    uint256 _size
  ) internal view returns(bytes32[] memory) {

      bytes32[] memory _returnArray = new bytes32[](_size);
      uint256 _position = position._at;

      assembly {
        //fast, unsafe storage to memory copy
        for { let _i := 0 } lt(_i, _size) { _i := add(_i, 1) } {
          mstore(add(add(_returnArray, 0x20), mul(_i, 0x20)), sload(add(_position, _i)) )
        }
      }

      return _returnArray;
  }

  function setPositionAt(Position memory position, uint at) internal view {
      position._at = at;
  }

}
