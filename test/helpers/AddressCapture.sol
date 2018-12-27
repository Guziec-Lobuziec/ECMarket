pragma solidity 0.4.24;

import "../../contracts/manager/IAgreementFactory.sol";


contract AddressCapture is IAgreementFactory {

  IAgreementFactory private factory;
  address public addressCaptured;

  constructor(address _factory) public {
    factory = IAgreementFactory(_factory);
  }

  function create(
      address creator,
      bytes32[] name,
      bytes32[] description,
      uint blocksToExpiration,
      uint price,
      bytes extra
  ) public returns(address) {

    addressCaptured = factory.create(
      creator,
      name,
      description,
      blocksToExpiration,
      price,
      extra
      );

      return addressCaptured;

  }

}
