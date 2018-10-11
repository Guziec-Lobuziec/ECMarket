pragma solidity 0.4.23;

import "bytes/BytesLib.sol";

import "./IAgreementFactory.sol";
import "./Agreement1_1.sol";
import "./Agreement1_2.sol";


contract AgreementFactory is IAgreementFactory {

    using BytesLib for bytes;

    struct AgreementSpecification {
      bytes32[2] name;
      bytes32[8] description;
      uint blocksToExpiration;
      uint price;
      uint advancePayment;
      uint blocksToFallback;
      bool hasAdvancePayment;
    }

    address private agreementManager;
    address private tokenContract;
    uint private lowerExpirationLimit;
    uint private upperExpirationLimit;

    mapping(
      bytes4 =>
      function (
        AgreementSpecification memory, bytes memory, uint
      ) internal returns (uint)
    ) private resolver;

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

        resolver[bytes4(sha3(
          "setAdvancePayment(uint256,uint256)"
        ))] = setAdvancePayment;
    }

    function create(
        address creator,
        bytes32[2] name,
        bytes32[8] description,
        uint blocksToExpiration,
        uint price,
        bytes extra
    ) public returns(address) {

      address newAgreement = 0;

      AgreementSpecification memory spec = AgreementSpecification({
        name: name,
        description: description,
        blocksToExpiration: blocksToExpiration,
        price: price,
        advancePayment: 0,
        blocksToFallback: 0,
        hasAdvancePayment: false
      });

      expirationDateConstraint(spec);
      decodeExtra(spec, extra);

      newAgreement = new Agreement1_1(
        agreementManager,
        tokenContract,
        creator,
        price,
        spec.blocksToExpiration,
        name,
        description
      );
      return newAgreement;

    }

    function decodeExtra(
      AgreementSpecification memory context,
      bytes memory extra
    ) internal returns(AgreementSpecification) {

      uint index = 0;
      bytes4 signature;
      while(index < extra.length) {
        signature = toBytes4(extra,index);
        index += 4;
        index += resolver[signature](context, extra, index);
      }

    }

    function toBytes4(bytes memory array, uint start) internal pure returns(bytes4) {
        require(array.length >= (start + 4));
        bytes4 tempBytes4;

        assembly {
            tempBytes4 := div(mload(add(add(array, 0x20), start)), 0x100000000000000000000000000000000000000000000000000000000)
        }

        return tempBytes4;
    }

    function expirationDateConstraint(
      AgreementSpecification memory context
    ) internal returns (AgreementSpecification) {

      if(context.blocksToExpiration < lowerExpirationLimit)
        context.blocksToExpiration = lowerExpirationLimit;

      if(context.blocksToExpiration >= upperExpirationLimit)
        context.blocksToExpiration = upperExpirationLimit-1;

      return context;
    }

    function setAdvancePayment(
      AgreementSpecification memory context,
      bytes memory args,
      uint start
    ) internal returns (uint) {

      uint advancePayment = args.toUint(start);
      uint blocksToFallback = args.toUint(start+32);

      if(context.price < advancePayment)
        context.advancePayment = context.price;
      else
        context.advancePayment = advancePayment;

      if(context.blocksToExpiration < blocksToFallback)
        context.blocksToFallback = context.blocksToExpiration;
      else
        context.blocksToFallback = blocksToFallback;

      return 64;

    }

}
