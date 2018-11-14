pragma solidity 0.4.24;

import "../../contracts/machine/StateMachine.sol";
import "../../contracts/utils/StorageController.sol";


contract StateMachineWithStorage is StorageController, StateMachine {

  using StorageManagement for StorageManagement.StorageObject;

  uint256 constant private STATE_STORAGE_SIZE = 256;

  //should occupy slot after other storage variables
  StorageManagement.StorageObject private object;


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
    ) public {

      start.initialze(object);

      for(uint i = 0; i < states.length; i++) {

        object.setSPointerFor(
          states[i],
          StorageUtils.SPointer({
            _start: i*STATE_STORAGE_SIZE + StorageManagement.getFreeStorageSlot(),
            _length: STATE_STORAGE_SIZE,
            _at: 0
          })
        );

      }

      object.setCurrentContext(entryState);

    }

    function setNewState(bytes32 next) public self returns(bool) {
      super.setNewState(next);
      object.setCurrentContext(next);
    }

}
