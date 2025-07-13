// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract AgentRegistry {
    struct Agent {
        address agentAddress;
        string name;
        uint256 approvedUsers;
        uint256 trustScore; // 0 to 100
        bool isActive;
    }

    mapping(address => Agent) public agents;
    address public admin;

    event AgentRegistered(address indexed agent, string name);
    event AgentStatusChanged(address indexed agent, bool isActive);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function registerAgent(address _agentAddress, string memory _name) public onlyAdmin {
        require(!agents[_agentAddress].isActive, "Agent already active");
        agents[_agentAddress] = Agent(_agentAddress, _name, 0, 50, true);
        emit AgentRegistered(_agentAddress, _name);
    }

    function updateTrustScore(address _agent, uint256 newScore) public onlyAdmin {
        require(agents[_agent].isActive, "Agent not active");
        require(newScore <= 100, "Invalid score");
        agents[_agent].trustScore = newScore;
    }

    function disableAgent(address _agentAddress) public onlyAdmin {
        agents[_agentAddress].isActive = false;
        emit AgentStatusChanged(_agentAddress, false);
    }

    function getAgent(address _agentAddress) public view returns (Agent memory) {
        return agents[_agentAddress];
    }
}