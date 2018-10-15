pragma solidity 0.4.23;

import "../../contracts/AbstractState.sol";
import "../../contracts/IArbitraryStorage.sol";

contract StateForTests3 is AbstractState {

    event Executed(string what, bytes32 storageDiff);

    function setUint(uint x) public {
      bytes32[] memory tmp = new bytes32[](1);
      tmp[0] = bytes32(x);
      emit Executed("setUint(uint)", tmp[0]);
      IArbitraryStorage(this).setBytes(0,tmp);
    }

    function getUint() public view returns(uint) {
        bytes32[] memory tmp = IArbitraryStorage(this).getBytes(0,1);
        return uint(tmp[0]);
    }

}
