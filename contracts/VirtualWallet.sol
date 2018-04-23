pragma solidity 0.4.21;


contract VirtualWallet {


    function getBalance() public view returns (uint balance) {
        return address(this).balance;
    }



    function payIn(address _from, uint amount) public payable
    {
        _from.transfer(amount);
    }
}
