// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Remittance {
    event Remitted(address indexed from, address indexed to, uint256 amount, string note);

    function remit(address payable to, string memory note) public payable {
        require(msg.value > 0, "Must send some ether");
        to.transfer(msg.value);
        emit Remitted(msg.sender, to, msg.value, note);
    }
}
