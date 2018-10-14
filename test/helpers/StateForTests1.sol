pragma solidity 0.4.23;

import "../../contracts/IStateMachine.sol";

contract StateForTests1 {

  event Executed(string what);


    function test() public {
      emit Executed("test()");
    }

    function transition(bool flip) public {
      if(flip) {
        emit Executed("transition(bool) true");
        bytes32[] memory reachable = IStateMachine(this).getListOfReachableStates();
        IStateMachine(this).setNewState(reachable[0]);

      } else {
        emit Executed("transition(bool) false");
      }
    }

    function differentCode() public {
      emit Executed("differentCode()");
      bytes32[] memory reachable = IStateMachine(this).getListOfReachableStates();
      IStateMachine(this).setNewState(reachable[1]);
    }

    function currentState() public view returns(bytes32) {
      return (IStateMachine(this)).getCurrentState();
    }

}
