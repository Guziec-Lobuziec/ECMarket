pragma solidity 0.4.23;

import "./IStateMachineBase.sol";


contract IState is IStateMachineBase{

  function getMachineState() public view returns (bytes32);
  function getMachine() public view returns (address);
  function getMachineReachableStates() public view returns (bytes32[]);

}
