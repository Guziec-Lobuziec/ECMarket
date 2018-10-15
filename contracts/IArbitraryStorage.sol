pragma solidity 0.4.23;


contract IArbitraryStorage {

    function setBytes(uint256 _position, bytes32[] _value) public;
    function getBytes(uint256 _position, uint256 _size) public view returns(bytes32[]);

}
