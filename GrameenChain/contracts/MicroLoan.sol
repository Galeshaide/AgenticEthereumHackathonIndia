
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MicroLoan {
    struct Loan {
        uint256 amount;
        uint256 dueDate;
        uint256 interestRate;
        bool isRepaid;
    }

    mapping(address => Loan[]) public userLoans;
    address public admin;

    event LoanIssued(address indexed user, uint256 amount, uint256 dueDate);
    event LoanRepaid(address indexed user, uint256 amount);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can issue loans");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function issueLoan(address _user, uint256 _amount, uint256 _duration, uint256 _interestRate) public onlyAdmin {
        uint256 dueDate = block.timestamp + _duration;
        userLoans[_user].push(Loan(_amount, dueDate, _interestRate, false));
        payable(_user).transfer(_amount);
        emit LoanIssued(_user, _amount, dueDate);
    }

    function repayLoan(uint256 _loanIndex) public payable {
        Loan storage loan = userLoans[msg.sender][_loanIndex];
        require(!loan.isRepaid, "Already repaid");
        uint256 interest = (loan.amount * loan.interestRate) / 100;
        require(msg.value >= loan.amount + interest, "Insufficient repayment");
        loan.isRepaid = true;
        emit LoanRepaid(msg.sender, msg.value);
    }

    function getLoans(address _user) public view returns (Loan[] memory) {
        return userLoans[_user];
    }
}
