pragma solidity 0.4.24;

contract IAgreementFactory {

    function create(
        address creator,
        bytes32[2] name,
        bytes32[8] description,
        uint blocksToExpiration,
        uint price,
        bytes extra
    ) public returns(address);

}
