pragma solidity 0.4.21;


contract VirtualWallet {

    uint private value;

    mapping (address=>uint) walletValue;

    function getBalance(address externalWallet) public view returns (uint balance) {
        return walletValue[this.balance];
    }



    function payIn() public payable
    {
        walletValue[this.balance] = msg.value;    
    }

    function payOut(uint amount) public payable
    {
        msg.sender.send(amount);
    }
}
