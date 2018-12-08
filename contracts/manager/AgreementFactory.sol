pragma solidity 0.4.24;

import "bytes/BytesLib.sol";

import "./IAgreementFactory.sol";
import "../agreements/Agreement.sol";


contract AgreementFactory is IAgreementFactory {

    address private agreementManager;
    address private tokenContract;
    address[] private stateMutators;
    uint private lowerExpirationLimit;
    uint private upperExpirationLimit;

    constructor(
      address _agreementManager,
      address _tokenContract,
      address[] _stateMutators,
      uint _lowerExpirationLimit,
      uint _upperExpirationLimit
      ) public {

        agreementManager = _agreementManager;
        tokenContract = _tokenContract;
        lowerExpirationLimit = _lowerExpirationLimit;
        upperExpirationLimit = _upperExpirationLimit;

        for(uint i = 0; i<_stateMutators.length; i++) {
          stateMutators.push(_stateMutators[i]);
        }
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

      if(blocksToExpiration < lowerExpirationLimit)
        blocksToExpiration = lowerExpirationLimit;

      if(blocksToExpiration > upperExpirationLimit)
        blocksToExpiration = upperExpirationLimit-1;

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
      address[] memory mutators = new address[](5);
      mutators[0] = stateMutators[0];
      mutators[1] = stateMutators[1];
      mutators[2] = stateMutators[1];
      mutators[3] = stateMutators[2];
      mutators[4] = stateMutators[2];
      bytes32[] memory stateIds = new bytes32[](5);
      stateIds[0] = 0x00;
      stateIds[1] = 0x01;
      stateIds[2] = 0x02;
      stateIds[3] = 0x03;
      stateIds[4] = 0x04;
      uint[] memory lengthOfReachableStates = new uint[](5);
      lengthOfReachableStates[0] = 2;
      lengthOfReachableStates[1] = 2;
      lengthOfReachableStates[2] = 2;
      lengthOfReachableStates[3] = 1;
      lengthOfReachableStates[4] = 0;
      bytes32[] memory arrayOfArraysOfReachableStates = new bytes32[](7);
      arrayOfArraysOfReachableStates[0] = 0x01;
      arrayOfArraysOfReachableStates[1] = 0x04;

      arrayOfArraysOfReachableStates[2] = 0x02;
      arrayOfArraysOfReachableStates[3] = 0x04;

      arrayOfArraysOfReachableStates[4] = 0x03;
      arrayOfArraysOfReachableStates[5] = 0x04;

      arrayOfArraysOfReachableStates[6] = 0x04;

      return new Agreement(
        mutators,
        stateIds,
        lengthOfReachableStates,
        arrayOfArraysOfReachableStates,
        0x00
      );
    }

}
