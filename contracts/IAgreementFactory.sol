pragma solidity 0.4.23;

contract IAgreementFactory {

    function create(
        address creator,
        bytes32[2] name,
        bytes32[8] description,
        uint blocksToExpiration,
        bytes  extra
    ) public returns(address);

}
