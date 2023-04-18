// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {AttackSucc} from "../src/AttackSucc.sol";
import {AttackFail} from "../src/AttackFail.sol";
import {ReentrancyBank} from "../src/ReentrancyBank.sol";
import {TrapReentrancyBank} from "../src/TrapReentrancyBank.sol";
import {CallFailed} from "../src/interfaces/BankErrors.sol";

contract CounterTest is Test {
    AttackSucc attackerSucc;
    AttackFail attackerFail;
    ReentrancyBank reentrancyBank;
    TrapReentrancyBank trapReentrancyBank;

    function setUp() public {
        reentrancyBank = new ReentrancyBank();
        trapReentrancyBank = new TrapReentrancyBank();
        attackerSucc = new AttackSucc(reentrancyBank);
        attackerFail = new AttackFail(trapReentrancyBank);
    }

    function test_AttackSucc() public {
        reentrancyBank.deposit{value: 10 ether}();
        assertEq(reentrancyBank.balances(address(this)), 10 ether);
        assertEq(reentrancyBank.balances(address(attackerSucc)), 0);

        attackerSucc.deposit{value: 1 ether}();
        assertEq(reentrancyBank.balances(address(attackerSucc)), 1 ether);

        attackerSucc.attack{gas: 3000_0000}();
        assertEq(address(attackerSucc).balance, 11 ether);
    }

    function test_RevertIf_AttackTrapBank() public {
        trapReentrancyBank.deposit{value: 10 ether}();
        assertEq(trapReentrancyBank.balances(address(this)), 10 ether);
        assertEq(trapReentrancyBank.balances(address(attackerFail)), 0);

        attackerFail.deposit{value: 1 ether}();
        assertEq(trapReentrancyBank.balances(address(attackerFail)), 1 ether);

        vm.expectRevert(CallFailed.selector);
        attackerFail.attack{gas: 3000_0000}();
    }
}
