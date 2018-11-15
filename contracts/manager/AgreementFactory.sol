pragma solidity 0.4.24;

import "bytes/BytesLib.sol";

import "./IAgreementFactory.sol";
import "../agreements/Agreement.sol";


contract AgreementFactory is IAgreementFactory {

    address private agreementManager;
    address private tokenContract;
    uint private lowerExpirationLimit;
    uint private upperExpirationLimit;

    constructor(
      address _agreementManager,
      address _tokenContract,
      uint _lowerExpirationLimit,
      uint _upperExpirationLimit
      ) public {

        agreementManager = _agreementManager;
        tokenContract = _tokenContract;
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
      address[] memory tmp1 = new address[](1);
      bytes32[] memory tmp2 = new bytes32[](1);
      uint[] memory tmp3 = new uint[](1);
      bytes32[] memory tmp4 = new bytes32[](1);

      return new Agreement(
        tmp1,
        tmp2,
        tmp3,
        tmp4,
        0x0
      );
    }

}
