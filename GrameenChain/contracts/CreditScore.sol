// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CreditScore {
    mapping(address => uint256) public scores;
    address public admin;

    event ScoreUpdated(address indexed user, uint256 newScore);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can update scores");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function updateScore(address _user, uint256 _score) public onlyAdmin {
        require(_score <= 100, "Score must be 0-100");
        scores[_user] = _score;
        emit ScoreUpdated(_user, _score);
    }

    function getScore(address _user) public view returns (uint256) {
        return scores[_user];
    }
}
