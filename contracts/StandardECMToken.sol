pragma solidity 0.4.24;

import "./IEIP20.sol";

contract StandardECMToken is IEIP20 {

    mapping (address => uint) private basicRating;

    mapping (address => uint256) private walletValue;
    mapping (address => mapping(address => uint256)) private allowed;
    uint256 private supply;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function balanceOf(address owner) public view returns (uint256) {
        return walletValue[owner];
    }

    function totalSupply() public view returns (uint256) {
      return supply;
    }

    function payIn() public payable {
        require(walletValue[msg.sender] <= walletValue[msg.sender] + msg.value);
        require(supply <= supply + msg.value);
        walletValue[msg.sender] += msg.value;
        supply += msg.value;
        emit Transfer(address(0),msg.sender,msg.value);
    }

    function payOut(uint256 amount) public payable {
        require(walletValue[msg.sender] >= amount, "Not enough assets");
        walletValue[msg.sender] -= amount;
        supply -= amount;
        msg.sender.transfer(amount);
        emit Transfer(msg.sender,address(0),amount);
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(walletValue[msg.sender] >= value, "Not enough assets");
        require(walletValue[to] <= walletValue[to] + value);
        require((to != 0) && (to != address(this)));
        walletValue[msg.sender] -= value;
        walletValue[to] += value;
        emit Transfer(msg.sender,to,value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(walletValue[from] >= value, "Not enough assets");
        require(allowed[from][msg.sender] >= value, "Not allowed to transfer given amount");
        require(walletValue[to] <= walletValue[to] + value);
        require((to != 0) && (to != address(this)));
        allowed[from][msg.sender] -= value;
        walletValue[from] -= value;
        walletValue[to] += value;
        emit Transfer(from,to,value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        require((value == 0) || (allowed[msg.sender][spender] == 0));

        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender,spender,value);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return allowed[owner][spender];
    }

    function getRating(address ratingSystem) public view returns (uint) {
        return 0;
    }
}
