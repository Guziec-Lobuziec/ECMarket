pragma solidity 0.4.23;

import "../../contracts/AbstractState.sol";

contract StateForTests1 is AbstractState {

  event Executed(string what);


    function test() public {
      emit Executed("test()");
    }

    function transition(bool flip) public {
      if(flip) {
        emit Executed("transition(bool) true");
        bytes32[] memory reachable = getMachineReachableStates();
        setMachineNextState(reachable[0]);

      } else {
        emit Executed("transition(bool) false");
      }
    }

    function differentCode() public {
      emit Executed("differentCode()");
      bytes32[] memory reachable = getMachineReachableStates();
      setMachineNextState(reachable[1]);
    }

}
