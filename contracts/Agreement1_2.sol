pragma solidity 0.4.23;

import "./Agreement1_1.sol";

contract Agreement1_2 is Agreement1_1 {

    uint private advancePayment;
    uint private blocksToFallback;

    constructor(
      address _agreementManager,
      address _wallet,
      address creator,
      uint _price,
      uint _blocksToExpiration,
      bytes32[2] _name,
      bytes32[8] _description,
      uint _advancePayment,
      uint _blocksToFallback
    ) Agreement1_1(
      _agreementManager,
      _wallet,
      creator,
      _price,
      _blocksToExpiration,
      _name,
      _description
    ) public {
      advancePayment = _advancePayment;
      blocksToFallback = _blocksToFallback;
    }

    function getAdvancePayment() public view returns(uint) {
      return advancePayment;
    }

    function getBlocksToFallback() public view returns(uint) {
      return blocksToFallback;
    }

}
