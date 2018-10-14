pragma solidity 0.4.23;

import "../../contracts/IStateMachine.sol";

contract StateForTests2 {

  event Executed(string what);


    function uniqueForState() public {
      emit Executed("uniqueForState()");
    }

    function backToStart() public {
      emit Executed("backToStart()");
      bytes32[] memory reachable = IStateMachine(this).getListOfReachableStates();
      IStateMachine(this).setNewState(reachable[0]);
    }

    function illegalTransition() public {
      IStateMachine(this).setNewState(
        0x1000000000000000000000000000000000000000000000000000000000000000
      );
    }

    function currentState() public view returns(bytes32) {
      return (IStateMachine(this)).getCurrentState();
    }

}
