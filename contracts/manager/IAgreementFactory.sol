pragma solidity 0.4.24;

contract IAgreementFactory {

    function create(
        address creator,
        bytes32[] name,
        bytes32[] description,
        uint blocksToExpiration,
        uint price,
        bytes extra
    ) public returns(address);

}
