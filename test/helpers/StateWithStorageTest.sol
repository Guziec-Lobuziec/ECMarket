pragma solidity 0.4.24;

import "../../contracts/machine/AbstractState.sol";

contract StateWithStorageTest is AbstractState {

    function setBytes32(bytes32 val) public {

    }

    function getBytes32() public view returns(bytes32) {
        
    }

    function transition() public {
      bytes32[] memory reachable = getMachineReachableStates();
      setMachineNextState(reachable[0]);
    }

}
