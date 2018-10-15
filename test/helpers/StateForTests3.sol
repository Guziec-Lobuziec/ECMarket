pragma solidity 0.4.23;

import "../../contracts/AbstractState.sol";
import "../../contracts/IArbitraryStorage.sol";

contract StateForTests3 is AbstractState {

    event Executed(string what, bytes32[] storageDiff);

    function setUint(uint x) public {
      bytes32[] memory tmp = new bytes32[](1);
      tmp[0] = bytes32(x);
      emit Executed("setUint(uint)", tmp);
      IArbitraryStorage(this).setBytes(0,tmp);
    }

    function getUint() public view returns(uint) {
        bytes32[] memory tmp = IArbitraryStorage(this).getBytes(0,1);
        return uint(tmp[0]);
    }

    function setBytes32Array(bytes32[] x) public {
      emit Executed("setBytes32Array(bytes32[])", x);
      bytes32[] memory size = new bytes32[](1);
      size[0] = bytes32(x.length);
      IArbitraryStorage(this).setBytes(1,size);
      IArbitraryStorage(this).setBytes(2,x);
    }

    function getBytes32Array() public view returns(bytes32[]) {
        bytes32[] memory size = IArbitraryStorage(this).getBytes(1,1);
        bytes32[] memory tmp = IArbitraryStorage(this).getBytes(2,uint(size[0]));
        return tmp;
    }

    function getStorageSize() public view returns(uint) {
        return IArbitraryStorage(this).storageSize();
    }

}
