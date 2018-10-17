pragma solidity 0.4.24;

import "./IState.sol";
import "./IStateMachine.sol";


contract AbstractState is IState {

  modifier isMachine {
      require(amIMachine());
      _;
  }

  function setMachineNextState(bytes32 next) internal isMachine returns (bool) {
      return IStateMachine(this).setNewState(next);
  }
  function getMachineState() public view isMachine returns (bytes32) {
      return IStateMachine(this).getCurrentState();
  }
  function getMachine() public view isMachine returns (address) {
      return this;
  }
  function getMachineReachableStates() public view isMachine returns (bytes32[]) {
      return  IStateMachine(this).getListOfReachableStates();
  }

  function amIMachine() public view returns (bool) {
      return IStateMachine(this).amIMachine.gas(2300)();
  }

}
