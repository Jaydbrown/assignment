// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract saveEther {
    uint256 public totalSupply;
    address public owner;

    mapping(address => uint256) public balance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Deposit(address indexed from, uint256 value);

    constructor() {
        owner = msg.sender;
    }

    function checkIndividualBalances(address account) public view returns (uint256) {
        return balance[account];
    }

    function depositToken() public payable {
        require(msg.sender != address(0), "cannot get a token from address zero");
        balance[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdrawSavings(uint256 _value) public {
        require(msg.sender != address(0), "cannot send a token to address zero");
        require(balance[msg.sender] >= _value, "insufficient balance");
        balance[msg.sender] -= _value;
        payable(msg.sender).transfer(_value);
        emit Transfer(msg.sender, msg.sender, _value);
    }

    receive() external payable {
        balance[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
}