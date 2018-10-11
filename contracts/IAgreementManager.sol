pragma solidity 0.4.23;

contract IAgreementManager {

    event AgreementCreation(address created);
    function setAgreementFactory(address _factory) public;
    function create(
      bytes32[2] name,
      bytes32[8] description,
      uint blocksToExpiration,
      uint price,
      bytes extra
    ) public returns (address);
    function remove() public;
    function search() public view returns (address[64]);
    function checkReg(address agreementAddress) public view returns (bool);

}
