pragma solidity 0.4.24;


library StorageUtils {

    uint256 constant internal SPOINTER_SIZE = 3;

    struct SPointer{
      uint256 _start;
      uint256 _length;
      uint256 _at;
    }

    function setSlots(SPointer memory pointer, bytes32[] memory _value) internal {
      uint256 _valueSize = _value.length;
      uint256 _position = pointer._at + pointer._start;

      require(pointer._at + _valueSize - 1 < pointer._length);

      assembly {
        //fast, unsafe memory to storage copy
        for{ let _i := 0 } lt(_i, _valueSize) { _i := add(_i, 1) } {
          //get 32 bytes from memory _value+32 + (i*32)
          sstore(add(_position, _i), mload(add(add(_value, 0x20), mul(_i, 0x20))))
        }
      }

  }

  function getSlots(
    SPointer memory pointer,
    uint256 _size
  ) internal view returns(bytes32[] memory) {

      bytes32[] memory _returnArray = new bytes32[](_size);
      uint256 _position = pointer._at + pointer._start;

      require(pointer._at + _size - 1 < pointer._length);

      assembly {
        //fast, unsafe storage to memory copy
        for { let _i := 0 } lt(_i, _size) { _i := add(_i, 1) } {
          //get 32 bytes from slot _position + _i
          mstore(add(add(_returnArray, 0x20), mul(_i, 0x20)), sload(add(_position, _i)) )
        }
      }

      return _returnArray;
  }

  function setBytes(SPointer memory pointer, bytes memory _value) internal {

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

      setSlots(pointer,_valueSize);

      SPointer memory dataLocation = SPointer({
        _start: 0,
        _length: uint(-1),
        _at: uint(keccak256(abi.encodePacked(pointer._at + pointer._start)))
      });

      setSlots(dataLocation,_valToStore);
  }

  function getBytes(SPointer memory pointer) internal view returns(bytes memory) {

      bytes32[] memory retSize = getSlots(pointer, 1);

      SPointer memory dataLocation = SPointer({
        _start: 0,
        _length: uint(-1),
        _at: uint(keccak256(abi.encodePacked(pointer._at + pointer._start)))
      });

      bytes32[] memory _outputVal = getSlots(
        dataLocation,
        (uint(retSize[0])+31)/32
      );

      bytes memory _retVal = new bytes(uint(retSize[0]));

      assembly {
        let _outputSize := mload(_outputVal)
        //copy 32*_outputSize bytes from _outputVal to _retVal
        for { let _i := 0 } lt(_i, _outputSize) { _i := add(_i, 1) } {
          mstore(add(add(_retVal, 0x20), mul(_i, 0x20)), mload(add(add(_outputVal, 0x20), mul(_i, 0x20))))
        }
      }

      return _retVal;
  }

  function setMapping(SPointer memory pointer, bytes32 key, bytes32[] value) internal {

      SPointer memory dataLocation = SPointer({
        _start: 0,
        _length: uint(-1),
        _at: uint(keccak256(abi.encodePacked(key,pointer._at + pointer._start)))
      });

      setSlots(dataLocation,value);

  }

  function getMapping(
    SPointer memory pointer,
    bytes32 key,
    uint size
  ) internal view returns(bytes32[] memory) {

      SPointer memory dataLocation = SPointer({
        _start: 0,
        _length: uint(-1),
        _at: uint(keccak256(abi.encodePacked(key,pointer._at + pointer._start)))
      });

      return getSlots(dataLocation,size);

  }

  function getStoragePointerMapping(
    SPointer memory pointer,
    bytes32 key
  ) internal view returns(SPointer memory) {

    bytes32[] memory rawOutput = getMapping(pointer, key, SPOINTER_SIZE);
    SPointer memory outputPtr = SPointer({
      _start: uint(rawOutput[0]),
      _length: uint(rawOutput[1]),
      _at: uint(rawOutput[2])
    });

    return outputPtr;

  }

  function setPositionAt(SPointer memory pointer, uint at) internal view {
      pointer._at = at;
  }

  function getAbsolutSlotLocation(
    SPointer memory pointer
  ) internal view returns(uint256) {
    return pointer._at + pointer._start;
  }

}
