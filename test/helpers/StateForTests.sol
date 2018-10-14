pragma solidity 0.4.23;

import "../../contracts/IStateMachine.sol";

contract StateForTests {

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

    function currentState() public view returns(bytes32) {
      return (IStateMachine(this)).getCurrentState();
    }

}
