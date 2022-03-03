//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
/*
    TODO: 
    1. Create a pool that people can put money in -> Complete
    2. Transfer money in and out of pool -> Complete
    3. Randomize distribution of funds -> WIP -- need to wait for Chainlink
    4. Unlock pool after some time interval -> WIP
    5. Change types to optimal values, ex: all uints should not be uint256 -> WIP
    6. Add modifiers -> WIP
    7. Start pool when certain parameters are reached
    - 

    4. How to figure out the time intervals
    - when does the pool start
    - would need to do -> time_now - time_pool_started < time_interval
*/
contract YoLottery {
    struct PoolTiming{
        uint startTime;
        uint interval;
    }

    // Ensure the address calling function is the owner
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // Ensure the address is not zero (burner)
    modifier validateAddress () {
        require(msg.sender != address(0), "Ensure sender address is not zero");
        _;
    }

    // Ensure the pool is not currently running
    modifier poolUnlocked (uint256 poolNumber) {
        require((block.timestamp - poolTime[poolNumber].startTime) >  poolTime[poolNumber].interval);
        _;
    }

    // Ensure the pool is currently running
    modifier poolLocked (uint256 poolNumber) {
        require((block.timestamp - poolTime[poolNumber].startTime) <  poolTime[poolNumber].interval);
        _;
    }

    // Ensure the pool exists
    modifier poolExists (uint256 poolNumber) {
        require(pools[poolNumber] == true);
        _;
    }

    // Ensure the pool does not exists
    modifier poolDoesNotExist (uint256 poolNumber) {
        require(pools[poolNumber] == false);
        _;
    }

    mapping(address => mapping(uint256 => uint256)) public balance; // I don't think I need this because we don't need to track how much a user put in the pool really
    mapping(address => uint256) public owedAmount; 
    mapping(uint256 => address[]) public participants;
    mapping(uint256 => bool) pools;
    mapping(uint256 => uint256) poolBalance;
    mapping(uint256 => PoolTiming) poolTime;
    
    address owner;

    constructor() {
        owner = msg.sender;
    }

    // Allow owner to create and initialize a pool
    function createPool(uint256 poolNumber, uint256 poolTimeInterval) external onlyOwner poolDoesNotExist(poolNumber) {
        pools[poolNumber] = true;
        poolTime[poolNumber].startTime = block.timestamp;
        poolTime[poolNumber].interval = poolTimeInterval;
        poolBalance[poolNumber] = 0;
    }
    // Allow owner to remove pool
    function removePool(uint256 poolNumber) external onlyOwner poolExists(poolNumber) poolUnlocked(poolNumber) {
        pools[poolNumber] = false;
        delete poolBalance[poolNumber];
        delete poolTime[poolNumber];
    }

    // Start pool only if minimum buy in reached
    function startPool(uint256 poolNumber) public poolExists(poolNumber) {

    }

    // Allow owner to change time interval if pool is not running
    function setPoolTimeInterval(uint256 poolNumber, uint256 poolTimeInterval) external onlyOwner poolUnlocked(poolNumber) {
        poolTime[poolNumber].interval = poolTimeInterval; 
    }

    // User deposits ETH into pool
    function depositPool(uint256 poolNumber) payable external validateAddress poolExists(poolNumber) poolLocked(poolNumber) {
        require(msg.sender.balance >= msg.value, "Ensure sender has enough funds to put in pool");
        address[] storage _participants;
        
        if (balance[msg.sender][poolNumber] > 0) {
            balance[msg.sender][poolNumber] = balance[msg.sender][poolNumber] + msg.value;
        } else {
            balance[msg.sender][poolNumber] = msg.value;
        }
        
        _participants = participants[poolNumber];
        _participants.push(msg.sender);

        participants[poolNumber] = _participants;
        
        poolBalance[poolNumber] = poolBalance[poolNumber] + msg.value; 
    }

    // Distribute the ETH in the pool to the participants
    function distributePool(uint256 poolNumber) external poolExists(poolNumber) poolUnlocked(poolNumber) {
        
        address[] memory _participants = participants[poolNumber];
        address distributerAddress;
        for (uint256 idx = 0; idx < _participants.length; idx++) {
            distributerAddress = _participants[idx]; 
            owedAmount[distributerAddress] = owedAmount[distributerAddress] + 1 ether; // Random number
            balance[distributerAddress][poolNumber] = 0;
        }
        poolBalance[poolNumber] = 0;
    }

    event Withdrawl(address indexed sender, uint256 withdrawedFunds);

    // User withdraws funds owed to them
    function withdraw() payable external {
        require(owedAmount[msg.sender] > 0, "User must have funds oweing to them"); // ensure user can only pull out their funds
        uint256 owedFunds = owedAmount[msg.sender];
        payable(msg.sender).transfer(owedFunds);
        owedAmount[msg.sender] = 0;
        emit Withdrawl(msg.sender, owedFunds);
    }

    
    // Deposit ETH into smart contract -- don't think this is correct
    function deposit(uint256 amount) payable external {
        require(msg.value == amount);
    }

    // Get the amount of ETH stored in the contract
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // Get the current amount of money deposited by the user
    function getBalance(uint256 poolNumber) external view returns (uint256) {
        return balance[msg.sender][poolNumber];
    }  

    // Get the amount owed to the user after the pool distribution
    function getOwedAmount() external view returns (uint256) {
        return owedAmount[msg.sender];
    }
}
