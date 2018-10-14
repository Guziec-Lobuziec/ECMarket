pragma solidity 0.4.23;

import "../../contracts/AbstractState.sol";

contract StateForTests2 is AbstractState {

  event Executed(string what);


    function uniqueForState() public {
      emit Executed("uniqueForState()");
    }

    function backToStart() public {
      emit Executed("backToStart()");
      bytes32[] memory reachable = getMachineReachableStates();
      setMachineNextState(reachable[0]);
    }

    function illegalTransition() public {
      setMachineNextState(
        0x2000000000000000000000000000000000000000000000000000000000000000
      );
    }

}
