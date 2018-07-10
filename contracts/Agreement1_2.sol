pragma solidity 0.4.23;

import "./AgreementManager.sol";
import "./StandardECMToken.sol";
import "./IAgreement.sol";


contract Agreement1_2 is IAgreement {

  function getName() public view returns(bytes32[2]) {
      return [bytes32(0), bytes32(0)];
  }

  function getDescription() public view returns(bytes32[8]) {
      return [bytes32(0), bytes32(0), bytes32(0), bytes32(0), bytes32(0), bytes32(0), bytes32(0), bytes32(0)];
  }

  function getAPIJSON() public view returns(string) {
    return "";
  }

}
