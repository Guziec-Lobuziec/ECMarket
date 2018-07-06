pragma solidity 0.4.23;


contract StandardECMToken {

    mapping (address => uint) private basicRating;

    mapping (address => uint256) private walletValue;
    mapping (address => mapping(address => uint256)) private allowed;

    function balanceOf(address externalWallet) public view returns (uint256 balance) {
        return walletValue[externalWallet];
    }

    function payIn() public payable {
        require(walletValue[msg.sender] <= walletValue[msg.sender] + msg.value);
        walletValue[msg.sender] += msg.value;
    }

    function payOut(uint256 amount) public payable {
        require(walletValue[msg.sender] >= amount, "Not enough assets");
        walletValue[msg.sender] -= amount;
        msg.sender.transfer(amount);
    }

    function transfer(address to, uint256 value) public returns (bool success) {
        require(walletValue[msg.sender] >= value, "Not enough assets");
        require(walletValue[to] <= walletValue[to] + value);
        require((to != 0) && (to != address(this)));
        walletValue[msg.sender] -= value;
        walletValue[to] += value;
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool success) {
        require(walletValue[from] >= value, "Not enough assets");
        require(allowed[from][msg.sender] >= value, "Not allowed to transfer given amount");
        require(walletValue[to] <= walletValue[to] + value);
        require((to != 0) && (to != address(this)));
        allowed[from][msg.sender] -= value;
        walletValue[from] -= value;
        walletValue[to] += value;
        return true;
    }

    function approve(address spender, uint256 value) returns (bool success) {
        require((value == 0) || (allowed[msg.sender][spender] == 0));

        allowed[msg.sender][spender] = value;
    }

    function getRating(address ratingSystem) public view returns (uint rating) {
        return 0;
    }
}
