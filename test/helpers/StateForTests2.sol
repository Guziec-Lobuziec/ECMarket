pragma solidity 0.4.24;

import "../../contracts/machine/AbstractState.sol";

contract StateForTests2 is AbstractState {

  event Executed(string what);


    function uniqueForState() public {
      emit Executed("uniqueForState()");
    }

    function backToStart() public {
      emit Executed("backToStart()");
      bytes32[] memory reachable = getMachineReachableStates();
      //0x1000000000000000000000000000000000000000000000000000000000000000
      setMachineNextState(reachable[0]);
    }

    function illegalTransition() public {
      setMachineNextState(
        0x2000000000000000000000000000000000000000000000000000000000000000
      );
    }

    function machineTransitionMechanismAbuse() public {
      bytes32[] memory reachable = getMachineReachableStates();
      //0x1000000000000000000000000000000000000000000000000000000000000000
      setMachineNextState(reachable[0]);
      reachable = getMachineReachableStates();
      //0x2000000000000000000000000000000000000000000000000000000000000000
      setMachineNextState(reachable[0]);
    }

    function nextStateCallAbuse() public {
      bytes32[] memory reachable = getMachineReachableStates();
      //0x1000000000000000000000000000000000000000000000000000000000000000
      setMachineNextState(reachable[0]);
      require(address(this).call(abi.encodeWithSignature("test()")));
    }

}
