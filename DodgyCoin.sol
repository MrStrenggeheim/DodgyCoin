pragma solidity ^0.8.4;
// SPDX-License-Identifier: UNLICENSED

// the worst trash token
contract DodgyCoin {

    // declarating and defining some variables
    string public constant name = "Dodgy Coin";
    string public constant symbol = "DODGY";
    uint8 public constant decimals = 16;

    event Approval(address indexed tokenfrom, address indexed spender, uint tokens);
    event Transfer(address indexed from, address indexed to, uint tokens);

    uint256 public totalSupply;
    uint16 public transferFee;
    address ownerAddress;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    modifier ownerOnly {
        require(msg.sender == ownerAddress, "No privileges to perform this action");
        _;
    }

    // this will contruct money
    constructor(uint256 total, uint16 fee) {
        totalSupply = total;
        transferFee = fee;
        ownerAddress = msg.sender;
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    // this will transfer money
    function transfer(address receiver, uint value) public returns (bool) {
        require(value <= balanceOf[msg.sender], "Insufficient balance");
        // deduct a 0.5% fee for no reason
        balanceOf[msg.sender] = balanceOf[msg.sender] - value;
        balanceOf[receiver] = balanceOf[receiver] + (value - value / transferFee);
        balanceOf[address(this)] = balanceOf[address(this)] + (value / transferFee);
        emit Transfer(msg.sender, receiver, value - value / transferFee);
        emit Transfer(msg.sender, address(this), value / transferFee);
        return true;
    }

    // this will transfer your money away
    function transferFrom(address from, address to, uint value) public returns (bool) {
        require(value <= balanceOf[from], "Insufficient balance");
        require(value <= allowance[from][msg.sender], "Insufficient delegated tokens");
        balanceOf[from] = balanceOf[from] - value;
        allowance[from][msg.sender] = allowance[from][msg.sender] - value;
        // deduct a 0.5% fee for no reason
        balanceOf[to] = balanceOf[to] + (value - value / transferFee);
        balanceOf[address(this)] = balanceOf[address(this)] + (value / transferFee);
        emit Transfer(from, to, value - value / transferFee);
        emit Transfer(from, address(this), value / transferFee);
        return true;
    }

    // this will make you a poor person if you dont watch out
    function changeOwner(address newOwner) public ownerOnly {
        ownerAddress = newOwner;
    }

    // this can be good and bad
    function changeFee(uint16 newFee) public ownerOnly {
        require(newFee > 0, "Fee must be positive");
        transferFee = newFee;
    }

    // this hurts
    function drop(address[] calldata recipients, uint256[] calldata values) public ownerOnly {
        for (uint256 i = 0; i < recipients.length; i++) {
            require(values[i] <= balanceOf[address(this)], "Insufficient balance");
            balanceOf[recipients[i]] = balanceOf[recipients[i]] + values[i];
            balanceOf[address(this)] = balanceOf[address(this)] - values[i];
            emit Transfer(address(this), recipients[i], values[i]);
        }
    }

    // this hurts as well
    function burn(uint256 value) public ownerOnly {
        require(value <= balanceOf[address(this)], "Insufficient balance");
        balanceOf[address(this)] = balanceOf[address(this)] - value;
        balanceOf[address(0x0)] = balanceOf[address(0x0)] + value;
        emit Transfer(address(this), address(0x0), value);
    }

    // since no one else does; this function does it
    function approve(address delegate, uint value) public returns (bool) {
        allowance[msg.sender][delegate] = value;
        emit Approval(msg.sender, delegate, value);
        return true;
    }
}
