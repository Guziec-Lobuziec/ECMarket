pragma solidity 0.4.21;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

import "../contracts/VirtualWallet.sol";


contract TestVirtualWallet {

    function testInitialBalanceOfWallet() {

        VirtualWallet testWallet = new VirtualWallet();

        uint expected = 0;

        Assert.equal(testWallet.getBalance(), expected, "Waller should have 0 units of basic token");

    }

    function testPayInBalanceOfWallet(){

        uint etherBalance = 3 ether; 
        VirtualWallet testWallet = new VirtualWallet();


        VirtualWallet testWallet1 = new VirtualWallet();
        testWallet.payIn(address(testWallet1),etherBalance);
        Assert.equal(testWallet.getBalance(),3, "Wallet should have 3 units of basic token");
    }

}
