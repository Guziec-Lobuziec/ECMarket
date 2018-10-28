pragma solidity 0.4.24;

import "./StorageUtils.sol";


contract AbstractEnhancedStorage {

    using StorageUtils for StorageUtils.Position;

    function getStoragePointer(bytes32 id) internal returns(StorageUtils.Position memory);

}
