// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IBank} from "./interfaces/IBank.sol";
import {NotEnoughBalance, CallFailed} from "./interfaces/BankErrors.sol";

contract TrapReentrancyBank is IBank {
    mapping(address account => uint256 balance) public balances;

    receive() external payable {
        deposit();
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external {
        if (balances[msg.sender] < amount) revert NotEnoughBalance();
        (bool success,) = msg.sender.call{value: amount}("");
        if (!success) revert CallFailed();
        balances[msg.sender] -= amount;
    }

    function withdraw() external {}
}
