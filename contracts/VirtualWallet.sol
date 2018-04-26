pragma solidity 0.4.21;


contract VirtualWallet {

    
    address private path;
    uint private value;

    mapping (address => uint) walletValue;

    function getBalance(address externalWallet) public view returns (uint balance) {
        value = walletValue[externalWallet];
        return value;
    }



    function payIn() public payable
    {
        walletValue[msg.sender] += msg.value;    
    }

    function payOut(uint amount) public payable
    {

        if(walletValue[msg.sender] >= amount) {
            walletValue[msg.sender] -= amount;
            msg.sender.transfer(amount);
         }
        
    }
}