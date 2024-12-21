// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VirtualDebateArena {
    address public owner;

    struct Debate {
        string topic;
        uint256 startTime;
        uint256 endTime;
        address[] participants;
        mapping(address => string) arguments;
        mapping(address => uint256) votes;
        bool isActive;
    }

    uint256 public debateCounter;
    mapping(uint256 => Debate) public debates;
    mapping(address => bool) public registeredUsers;

    event UserRegistered(address indexed user);
    event DebateCreated(uint256 indexed debateId, string topic, uint256 startTime, uint256 endTime);
    event ArgumentSubmitted(uint256 indexed debateId, address indexed participant, string argument);
    event Voted(uint256 indexed debateId, address indexed voter, address indexed participant);
    event DebateClosed(uint256 indexed debateId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier isRegisteredUser() {
        require(registeredUsers[msg.sender], "User is not registered");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function registerUser() external {
        require(!registeredUsers[msg.sender], "User is already registered");
        registeredUsers[msg.sender] = true;
        emit UserRegistered(msg.sender);
    }

    function createDebate(string memory _topic, uint256 _startTime, uint256 _endTime) external onlyOwner {
        require(_startTime < _endTime, "Start time must be before end time");

        Debate storage newDebate = debates[debateCounter++];
        newDebate.topic = _topic;
        newDebate.startTime = _startTime;
        newDebate.endTime = _endTime;
        newDebate.isActive = true;

        emit DebateCreated(debateCounter - 1, _topic, _startTime, _endTime);
    }

    function joinDebate(uint256 _debateId) external isRegisteredUser {
        Debate storage debate = debates[_debateId];
        require(debate.isActive, "Debate is not active");
        require(block.timestamp < debate.startTime, "Debate has already started");

        debate.participants.push(msg.sender);
    }

    function submitArgument(uint256 _debateId, string memory _argument) external isRegisteredUser {
        Debate storage debate = debates[_debateId];
        require(debate.isActive, "Debate is not active");
        require(block.timestamp >= debate.startTime && block.timestamp <= debate.endTime, "Debate is not in progress");

        debate.arguments[msg.sender] = _argument;
        emit ArgumentSubmitted(_debateId, msg.sender, _argument);
    }

    function vote(uint256 _debateId, address _participant) external isRegisteredUser {
        Debate storage debate = debates[_debateId];
        require(debate.isActive, "Debate is not active");
        require(block.timestamp >= debate.startTime && block.timestamp <= debate.endTime, "Debate is not in progress");

        debate.votes[_participant]++;
        emit Voted(_debateId, msg.sender, _participant);
    }

    function closeDebate(uint256 _debateId) external onlyOwner {
        Debate storage debate = debates[_debateId];
        require(debate.isActive, "Debate is not active");
        require(block.timestamp > debate.endTime, "Debate is still ongoing");

        debate.isActive = false;
        emit DebateClosed(_debateId);
    
    }
}
