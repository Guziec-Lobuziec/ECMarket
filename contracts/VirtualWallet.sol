pragma solidity 0.4.23;


contract VirtualWallet {

    mapping (address => uint) walletValue;

    function balanceOf(address externalWallet) public view returns (uint balance) {
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

    function transfer(address to, uint256 value) public returns (bool success) {
        require(balanceOf(msg.sender) >= value, "Not enough assets");
        walletValue[msg.sender] -= value;
        walletValue[to] += value;
    }
}
