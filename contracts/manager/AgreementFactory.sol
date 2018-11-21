pragma solidity 0.4.24;

import "bytes/BytesLib.sol";

import "./IAgreementFactory.sol";
import "../agreements/Agreement.sol";


contract AgreementFactory is IAgreementFactory {

    address private agreementManager;
    address private tokenContract;
    address private stateMutators;
    uint private lowerExpirationLimit;
    uint private upperExpirationLimit;

    constructor(
      address _agreementManager,
      address _tokenContract,
      address _stateMutators,
      uint _lowerExpirationLimit,
      uint _upperExpirationLimit
      ) public {

        agreementManager = _agreementManager;
        tokenContract = _tokenContract;
        stateMutators = _stateMutators;
        lowerExpirationLimit = _lowerExpirationLimit;
        upperExpirationLimit = _upperExpirationLimit;
    }

    function create(
        address creator,
        bytes32[] name,
        bytes32[] description,
        uint blocksToExpiration,
        uint price,
        bytes extra
    ) public returns(address) {

      Agreement newInstance = createAgreement();

      newInstance.init(
        agreementManager,
        tokenContract,
        creator,
        price,
        blocksToExpiration,
        name,
        description
      );

      return newInstance;

    }

    function createAgreement() private returns(Agreement) {
      address[] memory mutators = new address[](1);
      mutators[0] = stateMutators;
      bytes32[] memory stateIds = new bytes32[](1);
      stateIds[0] = 0x0;
      uint[] memory lengthOfReachableStates = new uint[](1);
      bytes32[] memory arrayOfArraysOfReachableStates = new bytes32[](1);

      return new Agreement(
        mutators,
        stateIds,
        lengthOfReachableStates,
        arrayOfArraysOfReachableStates,
        0x0
      );
    }

}
