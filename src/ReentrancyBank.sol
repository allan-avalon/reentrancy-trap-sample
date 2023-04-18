// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IBank} from "./interfaces/IBank.sol";
import {NotEnoughBalance, CallFailed} from "./interfaces/BankErrors.sol";

contract ReentrancyBank is IBank {
    mapping(address account => uint256 balance) public balances;

    receive() external payable {
        deposit();
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external {}

    function withdraw() external {
        uint256 amount = balances[msg.sender];
        (bool success,) = msg.sender.call{value: amount}("");
        if (!success) revert CallFailed();
        balances[msg.sender] = 0;
    }
}
