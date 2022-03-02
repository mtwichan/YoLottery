//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
/*
    Goal: 
    1. Create a pool that people can put money in
    2. Transfer money in and out of pool
*/
contract YoLottery {
    // address pay
    mapping(address => mapping(uint256 => uint256)) public balance;
    mapping(address => mapping(uint256 => uint256)) public owedAmount;
    mapping(uint256 => address[]) public participants;
    mapping(uint256 => uint256) poolBalance;
    mapping(uint256 => uint256) poolTime;
    constructor() {

    }

    // Deposit ETH into pool
    function depositPool(uint256 poolNumber) payable public {
        require(msg.sender != address(0), "Ensure sender address is not zero");
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

    // Distribute ETH from pool
    /* 
        Problem: time activated function
        1. time based transaction need to be done off chain. The logic
        to fire a function at some time interval does not exist natively
        
        Options:
        1. Use a provider see: https://ethereum.stackexchange.com/questions/58377/how-to-execute-a-time-based-transaction-heres-my-sample-contract
        2. Make it yourself
        Idea: poll off chain every so often to fire a function. Function will not fire unless the time requirements are met
        Use the native time variables to do this
        To support multiple pools need to store time requirements in map I think
        Idea: 
    */
    function distributePool(uint256 poolNumber) external {
        
        address[] storage _participants = participants[poolNumber];
        for (uint256 i = 0; i < _participants.length; i++) {
            // TODO: if user has not withdraw previous pool add more funds
            address distributeAddress = _participants[poolNumber]; 
            owedAmount[distributeAddress][poolNumber] = 1 ether;
            balance[distributeAddress][poolNumber] = 0;
        }
        poolBalance[poolNumber] = 0;
    }

    function withdraw(uint256 poolNumber) external {
        require(owedAmount[msg.sender][poolNumber] > 0, "User must have funds oweing to them"); // ensure user can only pull out their funds
        payable(msg.sender).transfer(owedAmount[msg.sender][poolNumber]);
        owedAmount[msg.sender][poolNumber] = 0;
    }

    
    // Deposit ETH into smart contract
    function deposit(uint256 amount) payable public {
        require(msg.value == amount);
    }

    // Get the amount of ETH stored in the contract
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getBalance(uint256 poolNumber) public view returns (uint256) {
        return balance[msg.sender][poolNumber];
    }

    function getOwedAmount(uint256 poolNumber) public view returns (uint256) {
        return owedAmount[msg.sender][poolNumber];
    }

}
