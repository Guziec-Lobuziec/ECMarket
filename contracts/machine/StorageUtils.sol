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
          //get 32 bytes from memory _value+32 + (i*32)
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
          //get 32 bytes from slot _position + _i
          mstore(add(add(_returnArray, 0x20), mul(_i, 0x20)), sload(add(_position, _i)) )
        }
      }

      return _returnArray;
  }

  function setBytes(Position memory position, bytes memory _value) internal {

      //can be optimised to pack bytes to same slot as size if size <= 31
      bytes32[] memory _valueSize = new bytes32[](1);
      bytes32[] memory _valToStore;
      assembly {
          //free memory pointer
          _valToStore := mload(0x40)
          //celi(_value.length / 32)
          let _sizeToStore := div(add(mload(_value), 0x1f), 0x20)
          //allocate _sizeToStore + 32
          mstore(0x40, add(_valToStore, add(mul(_sizeToStore, 0x20), 0x20)))
          //store bytes32 length
          mstore(_valToStore, _sizeToStore)

          //copy 32*_sizeToStore bytes from _value to _valToStore
          for { let _i := 0 } lt(_i, _sizeToStore) { _i := add(_i, 1) } {
            mstore(add(add(_valToStore, 0x20), mul(_i, 0x20)), mload(add(add(_value, 0x20), mul(_i, 0x20))))
          }

          //store _value.length in _valueSize[0]
          mstore(add(_valueSize, 0x20), mload(_value))
      }

      setSlots(position,_valueSize);

      Position memory dataLocation = Position({
        _at: uint(keccak256(abi.encodePacked(position._at)))
      });

      setSlots(dataLocation,_valToStore);
  }

  function getBytes(Position position) internal view returns(bytes memory) {

      bytes32[] memory _outputSize = getSlots(position, 1);

      Position memory dataLocation = Position({
        _at: uint(keccak256(abi.encodePacked(position._at)))
      });

      bytes32[] memory _outputVal = getSlots(
        dataLocation,
        (uint(_outputSize[0])+31)/32
      );

      bytes memory _retVal = new bytes(uint(_outputSize[0]));

      assembly {
        let _outputSize := mload(_outputVal)
        //copy 32*_outputSize bytes from _outputVal to _retVal
        for { let _i := 0 } lt(_i, _outputSize) { _i := add(_i, 1) } {
          mstore(add(add(_retVal, 0x20), mul(_i, 0x20)), mload(add(add(_outputVal, 0x20), mul(_i, 0x20))))
        }
      }

      return _retVal;
  }

  function setPositionAt(Position memory position, uint at) internal view {
      position._at = at;
  }

}
