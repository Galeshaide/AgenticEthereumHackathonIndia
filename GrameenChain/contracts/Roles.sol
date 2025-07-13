// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Roles {
    enum Role { None, User, Agent }

    mapping(address => Role) public roles;

    // Only the deployer (admin) should assign roles ideally
    function assignRole(address _addr, Role _role) public {
        roles[_addr] = _role;
    }

    function getRole(address _addr) public view returns (Role) {
        return roles[_addr];
    }
}
