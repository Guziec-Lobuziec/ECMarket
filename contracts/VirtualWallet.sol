pragma solidity 0.4.21;


contract VirtualWallet {

    
    address private path;
    uint private value;

    mapping (address => uint) walletValue;

    function getBalance(address externalWallet) public view returns (uint balance) {
        value = walletValue[path];
        return value;
    }



    function payIn() public payable
    {
        path = msg.sender;
        walletValue[path] += msg.value;    
    }

    function payOut(uint amount) public payable
    {
        path = msg.sender;
        if(walletValue[path] >= amount) {
            walletValue[path] -= amount;
            msg.sender.transfer(amount);
         }
        
    }
}