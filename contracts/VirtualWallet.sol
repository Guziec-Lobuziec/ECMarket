pragma solidity 0.4.23;


contract VirtualWallet {

    mapping (address => uint) walletValue;
    mapping (address => uint) basicRating;

    function getBalance(address externalWallet) public view returns (uint balance) {
        return walletValue[externalWallet];
    }

    function payIn() public payable {
        walletValue[msg.sender] += msg.value;
    }

    function payOut(uint amount) public payable {
        require(walletValue[msg.sender] >= amount);
        walletValue[msg.sender] -= amount;
        msg.sender.transfer(amount);

    }

    function getRating(address ratingSystem) public view returns (uint rating) {
        return 0;
    }
}
