pragma solidity 0.4.23;

import "../../contracts/AbstractState.sol";

contract StateWithStorage is AbstractState {

    event Executed(string what, string storageDiff);

    function setUint(uint x) public {
        setStorage(0,x);
    }

    function getUint() public view returns(uint) {
        return getStorage(0);
    }

}
