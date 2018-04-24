pragma solidity 0.4.21;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

import "../contracts/VirtualWallet.sol";


contract TestVirtualWallet {

    function testInitialBalanceOfWallet() {

        VirtualWallet testWallet = new VirtualWallet();

        uint expected = 0;

        Assert.equal(testWallet.getBalance(this), expected, "Waller should have 0 units of basic token");

    }


}
