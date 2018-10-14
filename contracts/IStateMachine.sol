pragma solidity 0.4.23;


contract IStateMachine {

  function getCurrentState() public view returns (bytes32);
  function getListOfReachableStates() public view returns (bytes32[]);
  function setNewState(bytes32 next) public returns (bool);

}
