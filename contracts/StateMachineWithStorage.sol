pragma solidity 0.4.24;

import "./IArbitraryStorage.sol";
import "./StateMachine.sol";


contract StateMachineWithStorage is StateMachine, IArbitraryStorage {

  bytes32[] private machineStorage;

  constructor(
    address[] mutators,
    bytes32[] states,
    uint[] lengthOfReachableStates,
    bytes32[] arrayOfArraysOfReachableStates,
    bytes32 entryState
    ) StateMachine(
      mutators,
      states,
      lengthOfReachableStates,
      arrayOfArraysOfReachableStates,
      entryState
    ) {}

  function setSlots(uint256 _position, bytes32[] memory _value) public self {

      bytes32[] storage _mStorage = machineStorage;
      uint256 _valueSize = _value.length;

      assembly {

        //arrays in storage are aligned to 32 bytes multipls
        //load size of storage array from slot
        let _mStorageSize := sload(_mStorage_slot)

        //actual data position of array in storage is given by sha3(slot_number)
        mstore(0x0, _mStorage_slot)
        let _mStoragePtr := sha3(0x0,0x20)

        //test if position + size we want to write to is lest than
        //size of array. If not set new size and store it
        if gt(add(_valueSize, _position), _mStorageSize) {
          _mStorageSize := add(_valueSize, _position)
          sstore(_mStorage_slot, _mStorageSize)
        }

        //fast, unsafe memory to storage copy
        for{ let _i := 0 } lt(_i, _valueSize) { _i := add(_i, 1) } {
          sstore(add(add(_mStoragePtr, _i), _position), mload(add(add(_value, 0x20), mul(_i, 0x20))))
        }

      }

  }

  function getSlots(
    uint256 _position,
    uint256 _size
  ) public view self returns(bytes32[]) {

      require(_position + _size <= machineStorage.length);
      bytes32[] storage _mStorage = machineStorage;
      bytes32[] memory _returnArray = new bytes32[](_size);

      assembly {

        //actual data position of array in storage is given by sha3(slot_number)
        mstore(0x0, _mStorage_slot)
        let _mStoragePtr := sha3(0x0, 0x20)

        //fast, unsafe storage to memory copy
        for { let _i := 0 } lt(_i, _size) { _i := add(_i, 1) } {
          mstore(add(add(_returnArray, 0x20), mul(_i, 0x20)), sload(add(_mStoragePtr, add(_i, _position))) )
        }

      }

      return _returnArray;
  }

  function storageSize() public view returns(uint) {
      return machineStorage.length;
  }

}
