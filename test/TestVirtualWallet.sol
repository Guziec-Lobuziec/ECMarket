pragma solidity 0.4.21;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

import "../contracts/VirtualWallet.sol";


contract TestVirtualWallet {

    function testInitialBalanceOfWallet() {

        VirtualWallet testWallet = VirtualWallet(DeployedAddresses.VirtualWallet());

        uint expected = 0;

        Assert.equal(testWallet.getBalance(tx.origin), expected, "Waller should have 0 units of basic token");

    }

}
