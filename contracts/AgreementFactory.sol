pragma solidity 0.4.23;

import "./IAgreementFactory.sol";
import "./Agreement1_1.sol";
import "./Agreement1_2.sol";

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
        bytes32[2] name,
        bytes32[8] description,
        uint blocksToExpiration,
        bytes32[] extra
    ) public returns(address) {

      if(blocksToExpiration < lowerExpirationLimit)
        blocksToExpiration = lowerExpirationLimit;

      if(blocksToExpiration >= upperExpirationLimit)
        blocksToExpiration = upperExpirationLimit-1;

      uint price = 0;
      uint advancePayment = 0;
      uint blocksToFallback = 0;
      address newAgreement = 0;

      if(extra.length == 0) {
        newAgreement = new Agreement1_1(
          agreementManager,
          tokenContract,
          creator,
          price,
          blocksToExpiration,
          name,
          description
        );
      }
      else if(extra.length == 3){
        price = uint(extra[1]);
        newAgreement = new Agreement1_1(
          agreementManager,
          tokenContract,
          creator,
          price,
          blocksToExpiration,
          name,
          description
        );
      }
      else if(extra.length == 11){
        price = uint(extra[1]);
        advancePayment = uint(extra[5]);
        blocksToFallback = uint(extra[8]);
        newAgreement = new Agreement1_2(
          agreementManager,
          tokenContract,
          creator,
          price,
          blocksToExpiration,
          name,
          description,
          advancePayment,
          blocksToFallback
        );
      } else {
        require(false);
      }

      return newAgreement;

    }

}
