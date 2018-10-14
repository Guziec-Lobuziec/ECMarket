pragma solidity 0.4.23;

import "../../contracts/IStateMutator.sol";


contract StateForTests is IStateMutator {

  event Executed(string what);


    function test() public {
      emit Executed("test()");
    }

}
