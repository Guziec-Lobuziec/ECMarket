pragma solidity 0.4.24;


contract IArbitraryStorage {

    function setSlots(uint256 _position, bytes32[] _value) public;
    function getSlots(uint256 _position, uint256 _size) public view returns(bytes32[]);
    function storageSize() public view returns(uint);

}
