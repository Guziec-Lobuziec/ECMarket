pragma solidity 0.4.23;

import "./IState.sol";
import "./IStateMachine.sol";


contract StateMachine is IStateMachine {

  uint256 constant FORWARD_GAS_LIMIT = 10000;

  struct State {
      bytes32[] reachableStates;
      IState mutator;
  }

  mapping(bytes32 => State) private machineStates;
  bytes32 private currentState;

  constructor(
    address[] mutators,
    bytes32[] states,
    uint[] lengthOfReachableStates,
    bytes32[] arrayOfArraysOfReachableStates,
    bytes32 entryState
    ) {

      State storage current = machineStates[0];
      uint offset;

      for(uint i = 0; i < states.length; i++) {
        current = machineStates[states[i]];

        for(uint j = 0; j < lengthOfReachableStates[i]; j++) {
          current.reachableStates.push(arrayOfArraysOfReachableStates[offset+j]);
        }

        offset += lengthOfReachableStates[i];
        current.mutator = IState(mutators[i]);
      }

      currentState = entryState;
    }

    function setNewState(bytes32 next) public returns (bool) {

      require(msg.sender == address(this), "State must be part of machine");

      bytes32[] storage reachable = machineStates[currentState].reachableStates;
      bool found = false;
      for(uint i = 0; i < reachable.length; i++)
        if(reachable[i] == next)
          found = true;

      require(found, "Illegal state transition");
      currentState = next;
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

      require(gasleft() > FORWARD_GAS_LIMIT);

      uint _limit = FORWARD_GAS_LIMIT;
      address _mutator = address(machineStates[currentState].mutator);

      assembly {

        let _callsize := calldatasize
        let _calldata := mload(0x40)
        mstore(0x40,add(_calldata,_callsize))
        calldatacopy(_calldata, 0x0, _callsize)

        let _result := delegatecall(sub(gas,_limit), _mutator, _calldata, _callsize, 0, 0)

        let _returnsize := returndatasize
        let _returndata := mload(0x40)
        mstore(0x40,add(_returndata,_returnsize))
        returndatacopy(_returndata, 0x0,_returnsize)

        switch _result
        case 0 { revert(_returndata, _returnsize) }
        default { return(_returndata, _returnsize) }

      }

    }

}
