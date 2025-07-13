// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SavingsPool {
    struct Deposit {
        uint256 amount;
        uint256 timestamp;
    }

    mapping(address => Deposit[]) public userDeposits;
    mapping(address => uint256) public totalSaved;
    address public admin;

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function deposit() public payable {
        require(msg.value > 0, "Deposit must be greater than 0");
        userDeposits[msg.sender].push(Deposit(msg.value, block.timestamp));
        totalSaved[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    function withdraw(uint256 _amount) public {
        require(totalSaved[msg.sender] >= _amount, "Insufficient balance");
        totalSaved[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount);
        emit Withdrawn(msg.sender, _amount);
    }

    function getDeposits(address _user) public view returns (Deposit[] memory) {
        return userDeposits[_user];
    }
}
