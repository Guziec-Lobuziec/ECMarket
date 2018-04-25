pragma solidity 0.4.21;


contract VirtualWallet {

    uint private value;

    mapping (address => uint) walletValue;

    function getBalance(address externalWallet) public view returns (uint balance) {
        return walletValue[this];
    }



    function payIn() public payable
    {
        walletValue[this] += msg.value;    
    }

    function payOut(uint amount) public payable
    {
        
        //   if(walletValue[msg.sender] >= amount) {
        //     walletValue[msg.sender] -= amount;
            msg.sender.transfer(amount);
        // }
        
    }
}