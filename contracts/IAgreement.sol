pragma solidity 0.4.23;

contract IAgreement {

    function getName() public view returns(bytes32[2]);
    function getDescription() public view returns(bytes32[8]);
    function getAPIJSON() public view returns(string);

}
