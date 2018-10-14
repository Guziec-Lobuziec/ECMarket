pragma solidity 0.4.23;

import "./IStateMachineBase.sol";

contract IStateMachine is IStateMachineBase{

  function setNewState(bytes32 next) public returns (bool);
  function getCurrentState() public view returns (bytes32);
  function getListOfReachableStates() public view returns (bytes32[] memory);

}
