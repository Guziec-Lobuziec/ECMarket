pragma solidity 0.4.24;

import "./IState.sol";
import "./IStateMachine.sol";
import "./StorageController.sol";


contract StateMachine is StorageController, IStateMachine {

  using StorageManagement for StorageManagement.StorageObject;

  //needs justification
  uint256 constant FORWARD_GAS_LIMIT = 10000;
  //needs justification
  uint256 constant private STATE_STORAGE_SIZE = 256;

  struct State {
      bytes32[] reachableStates;
      IState mutator;
  }

  mapping(bytes32 => State) private machineStates;
  bytes32 private currentState;
  bool private hasBeenRegisteredForStateTransition;
  //should occupy slot after other storage variables
  StorageManagement.StorageObject private object;

  modifier self {
      require(msg.sender == address(this));
      _;
  }

  constructor(
    address[] mutators,
    bytes32[] states,
    uint[] lengthOfReachableStates,
    bytes32[] arrayOfArraysOfReachableStates,
    bytes32 entryState
    ) {

      start.initialze(object);

      State storage current = machineStates[0x0];
      uint offset;

      for(uint i = 0; i < states.length; i++) {
        current = machineStates[states[i]];

        object.storagePointers[states[i]] = StorageUtils.SPointer({
          _start: i*STATE_STORAGE_SIZE + StorageManagement.getFreeStorageSlot(),
          _length: STATE_STORAGE_SIZE,
          _at: 0
        });

        for(uint j = 0; j < lengthOfReachableStates[i]; j++) {
          current.reachableStates.push(arrayOfArraysOfReachableStates[offset+j]);
        }

        offset += lengthOfReachableStates[i];
        current.mutator = IState(mutators[i]);
      }

      currentState = entryState;
      object.currentContext = entryState;
    }

    function setNewState(bytes32 next) public self returns (bool) {

      assert(!hasBeenRegisteredForStateTransition);

      bytes32[] storage reachable = machineStates[currentState].reachableStates;
      bool found = false;
      for(uint i = 0; i < reachable.length; i++)
        if(reachable[i] == next)
          found = true;

      require(found, "Illegal state transition");
      currentState = next;
      object.currentContext = next;
      hasBeenRegisteredForStateTransition = true;
    }

    function getCurrentState() public view returns (bytes32) {
      return currentState;
    }

    function getListOfReachableStates() public view returns (bytes32[]) {
      return machineStates[currentState].reachableStates;
    }

    function amIMachine() public view returns (bool) {
      return true;
    }

    function() external {

      assert(!hasBeenRegisteredForStateTransition);

      require(gasleft() > FORWARD_GAS_LIMIT);

      uint _limit = FORWARD_GAS_LIMIT;
      address _mutator = address(machineStates[currentState].mutator);

      bool _result;
      bytes[] memory _returndata;

      assembly {

        //calldata size
        let _callsize := calldatasize
        //get free memory pointer
        let _calldata := mload(0x40)
        //allocate memory
        mstore(0x40,add(_calldata,_callsize))
        //copy calldata
        calldatacopy(_calldata, 0x0, _callsize)

        //execute delegatecall on state mutator
        _result := delegatecall(sub(gas,_limit), _mutator, _calldata, _callsize, 0, 0)

        //returndata size
        let _returnsize := returndatasize
        //store as _returndata array size
        mstore(_returndata, _returnsize)
        //copy returndata
        returndatacopy(add(_returndata, 0x20), 0x0,_returnsize)

      }

      hasBeenRegisteredForStateTransition = false;

      assembly {
        //get _returndata array size
        let _returnsize := mload(_returndata)
        //if delegatecall was succesful return returndata otherwise revert
        switch _result
        case 0 { revert(add(_returndata, 0x20), _returnsize) }
        default { return(add(_returndata, 0x20), _returnsize) }

      }

    }

}
