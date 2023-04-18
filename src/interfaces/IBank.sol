// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IBank {
    function deposit() external payable;

    function withdraw(uint256 amount) external;

    function withdraw() external;
}
