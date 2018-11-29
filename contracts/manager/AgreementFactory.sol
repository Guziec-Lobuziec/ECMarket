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
      address[] memory mutators = new address[](3);
      mutators[0] = stateMutators[0];
      mutators[1] = stateMutators[1];
      mutators[2] = stateMutators[1];
      bytes32[] memory stateIds = new bytes32[](3);
      stateIds[0] = 0x00;
      stateIds[1] = 0x01;
      stateIds[2] = 0x02;
      uint[] memory lengthOfReachableStates = new uint[](3);
      lengthOfReachableStates[0] = 1;
      lengthOfReachableStates[1] = 1;
      lengthOfReachableStates[2] = 0;
      bytes32[] memory arrayOfArraysOfReachableStates = new bytes32[](2);
      arrayOfArraysOfReachableStates[0] = 0x01;
      arrayOfArraysOfReachableStates[1] = 0x02;

      return new Agreement(
        mutators,
        stateIds,
        lengthOfReachableStates,
        arrayOfArraysOfReachableStates,
        0x0
      );
    }

}
