pragma solidity 0.4.24;

import "../../contracts/machine/AbstractState.sol";

contract StateForTests1 is AbstractState {

  event Executed(string what);


    function test() public {
      emit Executed("test()");
    }

    function transition(bool flip) public {
      if(flip) {
        emit Executed("transition(bool) true");
        bytes32[] memory reachable = getMachineReachableStates();
        //0x2000000000000000000000000000000000000000000000000000000000000000
        setMachineNextState(reachable[0]);

      } else {
        emit Executed("transition(bool) false");
      }
    }

    function differentCode() public {
      emit Executed("differentCode()");
      bytes32[] memory reachable = getMachineReachableStates();
      //0x3000000000000000000000000000000000000000000000000000000000000000
      setMachineNextState(reachable[1]);
    }

}
