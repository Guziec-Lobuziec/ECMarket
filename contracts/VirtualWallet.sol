pragma solidity 0.4.21;


contract VirtualWallet {

    uint private value;

    function getBalance(address externalWallet) public view returns (uint balance) {
        return value;
    }



    function payIn() public payable
    {
        value = msg.value;    
    }

    function payOut(uint amount) public
    {
        value -= amount;
    }
}
