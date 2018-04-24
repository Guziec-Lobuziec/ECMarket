pragma solidity 0.4.21;


contract VirtualWallet {

    uint private value;

    function getBalance(address externalWallet) public view returns (uint balance) {
        return this.balance;
    }



    function payIn() public payable
    {
        value = msg.value;    
    }

    function payOut(uint amount) public payable
    {
        msg.sender.send(amount);
    }
}
