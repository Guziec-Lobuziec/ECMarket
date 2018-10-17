pragma solidity 0.4.24;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

import "../contracts/StandardECMToken.sol";


contract DummyMortal {

    address target;

    function DummyMortal(address _target) public payable {
        target = _target;
    }

    function kill() public {
        selfdestruct(target);
    }
}


contract TestIfStandardECMTokenBalanceIsInvariantToKill {

    function () public payable {}

    uint public initialBalance = 5000;

    StandardECMToken testWallet;

    function beforeAll() {
        testWallet = StandardECMToken(DeployedAddresses.StandardECMToken());
    }

    function testInitialBalanceOfWallet() {
        uint expected = 0;

        Assert.equal(testWallet.balanceOf(this), expected, "Wallet should have 0 units of basic token");
    }

    function testBalanceChangeOfTest() {

        uint expected = 1000;

        testWallet.payIn.value(expected)();
        Assert.equal(this.balance, initialBalance - expected, "Test balance after payIn");
        testWallet.payOut(expected);
        Assert.equal(this.balance, initialBalance, "Test balance after payIn");
    }

    function testSelfdestructionTransferEffects() {

        uint expected = 1000;
        uint sentToDummy = 1000;
        DummyMortal dummy = (new DummyMortal).value(sentToDummy)(address(testWallet));

        testWallet.payIn.value(expected)();

        Assert.equal(testWallet.balanceOf(this), expected, "Wallet should have 1000 units of basic token");

        dummy.kill();

        Assert.equal(testWallet.balanceOf(this), expected, "Wallet should have 1000 units of basic token");

        testWallet.payOut(expected);

        Assert.equal(testWallet.balanceOf(this), 0, "Wallet should have 0 units of basic token");
        Assert.equal(this.balance, initialBalance - sentToDummy, "Test balance after");
    }
}
