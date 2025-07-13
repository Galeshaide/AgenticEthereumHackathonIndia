// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./SoulboundToken.sol";

contract EscrowLoan {
    address public admin;
    SoulboundToken public sbt;

    enum LoanStatus { None, Active, Repaid, Defaulted }

    struct Loan {
        address borrower;
        uint amount;
        uint released;
        LoanStatus status;
        uint dueDate;
    }

    mapping(uint => Loan) public loans;
    uint public loanCounter = 0;

    constructor(address _sbt) {
        admin = msg.sender;
        sbt = SoulboundToken(_sbt);
    }

    function requestLoan(uint _amount, uint _duration) external {
        loans[loanCounter] = Loan({
            borrower: msg.sender,
            amount: _amount,
            released: 0,
            status: LoanStatus.Active,
            dueDate: block.timestamp + _duration
        });

        loanCounter++;
    }

    function fundLoan(uint _loanId) external payable {
        require(msg.value == loans[_loanId].amount, "Incorrect funding");
        require(loans[_loanId].released == 0, "Already funded");

        uint toRelease = msg.value / 2;
        loans[_loanId].released = toRelease;
        payable(loans[_loanId].borrower).transfer(toRelease);
    }

    function repayLoan(uint _loanId) external payable {
        Loan storage loan = loans[_loanId];
        require(msg.sender == loan.borrower, "Only borrower can repay");
        require(loan.status == LoanStatus.Active, "Not active loan");
        require(msg.value == loan.amount, "Full repayment required");

        loan.status = LoanStatus.Repaid;

        uint remaining = loan.amount - loan.released;
        payable(loan.borrower).transfer(remaining);

        // Reward: Update SBT reputation
        sbt.recordRepayment(_loanId);
    }

    function checkAndMarkDefault(uint _loanId) public {
        Loan storage loan = loans[_loanId];
        require(loan.status == LoanStatus.Active, "Loan is not active");
        require(block.timestamp > loan.dueDate, "Loan not yet overdue");

        loan.status = LoanStatus.Defaulted;

        // Penalty: Update SBT reputation
        sbt.recordDefault(_loanId);
    }
}
