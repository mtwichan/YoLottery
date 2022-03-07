//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
/*
    TODO: 
    1. Create a pool that people can put money in -> Complete
    2. Transfer money in and out of pool -> Complete
    3. Randomize distribution of funds -> WIP -- need to wait for Chainlink
    4. Unlock pool after some time interval -> WIP
    5. Change types to optimal values -> WIP
    6. Add modifiers -> Complete
    7. Start pool 
    - minimum buy in minimum total pool -> Complete
    8. Starting pool parameters -> Complete
    9. Add ticket system so fixed cost bets to get a ticket - each ticket gives a play in probability game
    10. Support ERC20 token (USDT) -> will need to write another contract
    11. Time release pool by letting user free it for small reward -> WIP
*/
contract YoLottery {
    
    /* Modifiers */

    // Ensure the address calling function is the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner of the contract can access this function");
        _;
    }

    // Ensure the address is not zero (burner)
    modifier validateAddress () {
        require(msg.sender != address(0), "Ensure sender address is not zero");
        _;
    }

    // Ensure the pool is not currently running
    modifier poolUnlocked (uint256 poolNumber) {
        require((block.timestamp - pool[poolNumber].startTime) >  pool[poolNumber].interval, "The pool is unlocked");
        _;
    }

    // Ensure the pool is currently running
    modifier poolLocked (uint256 poolNumber) {
        require((block.timestamp - pool[poolNumber].startTime) <  pool[poolNumber].interval, "The pool is locked");
        _;
    }

    // Ensure the pool exists
    modifier poolExists (uint256 poolNumber) {
        require(activePools[poolNumber] == true, "The pool already exists");
        _;
    }

    // Ensure the pool does not exists
    modifier poolDoesNotExist (uint256 poolNumber) {
        require(activePools[poolNumber] == false, "The pool does not exist");
        _;
    }

    /* Variables */
    struct Pool{
        uint256 startTime;
        uint256 interval;
        uint256 balance;
        uint256 minBuyIn;
        address[] participants;
    }
    mapping(address => mapping(uint256 => uint256)) public balance; // I don't think I need this because we don't need to track how much a user put in the pool really
    mapping(address => uint256) public owedAmount; 
    // mapping(uint256 => mapping(address => bool)) participants;
    mapping(address => mapping(uint256 => bool)) public participants;
    mapping(uint256 => bool) activePools;
    mapping(uint256 => Pool) pool;
    
    address owner;
    
    /* Events */
    event Withdrawl(address indexed sender, uint256 withdrawedFunds);

    /* Functions */
    constructor() {
        owner = msg.sender;
    }

    // Allow owner to create and initialize a pool
    function createPool(uint256 poolNumber, uint256 poolTimeInterval, uint256 poolBuyIn) external onlyOwner poolDoesNotExist(poolNumber) {
        activePools[poolNumber] = true;
        pool[poolNumber].interval = poolTimeInterval;
        pool[poolNumber].minBuyIn = poolBuyIn;
    }

    // Allow owner to remove pool
    function removePool(uint256 poolNumber) external onlyOwner poolExists(poolNumber) poolUnlocked(poolNumber) {
        delete activePools[poolNumber];
        delete pool[poolNumber];
    }

    // Allow owner to start a pool
    function startPool(uint256 poolNumber) public onlyOwner poolExists(poolNumber) {
        pool[poolNumber].startTime = block.timestamp;
    }

    // User deposits ETH into pool
    function depositPool(uint256 poolNumber) payable external validateAddress poolExists(poolNumber) poolLocked(poolNumber) {
        require(msg.value >= pool[poolNumber].minBuyIn, "Deposited ETH must be greater or equal to the buy in");

        if (balance[msg.sender][poolNumber] > 0) {
            balance[msg.sender][poolNumber] = balance[msg.sender][poolNumber] + msg.value;
        } else {
            balance[msg.sender][poolNumber] = msg.value;
            pool[poolNumber].participants.push(msg.sender);
        }
        pool[poolNumber].balance = pool[poolNumber].balance + msg.value;
    }

    // Distribute the ETH in the pool to the participants
    function distributePool(uint256 poolNumber) external poolExists(poolNumber) poolUnlocked(poolNumber) {
        address[] memory _participants = pool[poolNumber].participants;
        address distributerAddress;
        uint256 poolBalance = pool[poolNumber].balance;
        
        for (uint256 idx = 0; idx < _participants.length; idx++) {
            distributerAddress = _participants[idx]; 
            owedAmount[distributerAddress] = owedAmount[distributerAddress] + 1 ether; // Random number
            balance[distributerAddress][poolNumber] = 0;
        }
        pool[poolNumber].balance = 0;
        pool[poolNumber].participants = new address[](0);
    }

    // User withdraws funds owed to them
    function withdraw() payable external {
        require(owedAmount[msg.sender] > 0, "User must have funds oweing to them"); // ensure user can only pull out their funds
        uint256 owedFunds = owedAmount[msg.sender];
        payable(msg.sender).transfer(owedFunds); // Look at best practices -- this may not be correct
        owedAmount[msg.sender] = 0;
        emit Withdrawl(msg.sender, owedFunds);
    }

    
    // Deposit ETH into smart contract -- don't think this is correct
    function deposit(uint256 amount) payable external {
        require(msg.value == amount);
    }

    // Allow owner to set  time interval if pool is not running
    function setPoolTimeInterval(uint256 poolNumber, uint256 poolTimeInterval) external onlyOwner poolUnlocked(poolNumber) {
        pool[poolNumber].interval = poolTimeInterval; 
    }

    // Get the amount of ETH stored in the contract
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // Get the current amount of money deposited by the user
    function getBalance(uint256 poolNumber) external view returns (uint256) {
        return balance[msg.sender][poolNumber];
    }  

    // Get the amount of time left until the specified pool unlocks
    function getPoolUnlockTime(uint256 poolNumber) external view returns (uint256) {
        return block.timestamp - pool[poolNumber].startTime;
    }

    // Get all metadata pertaining to a specific pool instance
    function getPoolData(uint256 poolNumber) external view returns (Pool memory) {
        return pool[poolNumber];
    }

    // Get the amount owed to the user after the pool distribution
    function getOwedAmount() external view returns (uint256) {
        return owedAmount[msg.sender];
    }
}
