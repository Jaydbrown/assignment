// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {saveEther} from "../src/saveEther.sol";

contract SaveEtherTest is Test {
    saveEther public vault;

    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");

    function setUp() public {
        vault = new saveEther();
        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);
    }

    function test_OwnerIsSetOnDeploy() public view {
        assertEq(vault.owner(), address(this));
    }

    function test_Deposit_Success() public {
        vm.prank(alice);
        vault.depositToken{value: 1 ether}();
        assertEq(vault.balance(alice), 1 ether);
    }

    function test_Deposit_AccumulatesBalance() public {
        vm.startPrank(alice);
        vault.depositToken{value: 1 ether}();
        vault.depositToken{value: 0.5 ether}();
        vm.stopPrank();
        assertEq(vault.balance(alice), 1.5 ether);
    }

    function test_Deposit_EmitsEvent() public {
        vm.prank(alice);
        vm.expectEmit(true, false, false, true);
        emit saveEther.Deposit(alice, 1 ether);
        vault.depositToken{value: 1 ether}();
    }

    function test_Withdraw_Success() public {
        vm.startPrank(alice);
        vault.depositToken{value: 2 ether}();
        uint256 balanceBefore = alice.balance;
        vault.withdrawSavings(1 ether);
        vm.stopPrank();

        assertEq(vault.balance(alice), 1 ether);
        assertEq(alice.balance - balanceBefore, 1 ether);
    }

    function test_Withdraw_FullAmount() public {
        vm.startPrank(alice);
        vault.depositToken{value: 2 ether}();
        vault.withdrawSavings(2 ether);
        vm.stopPrank();
        assertEq(vault.balance(alice), 0);
    }

    function test_Withdraw_RevertIf_InsufficientBalance() public {
        vm.prank(alice);
        vault.depositToken{value: 1 ether}();

        vm.prank(alice);
        vm.expectRevert("insufficient balance");
        vault.withdrawSavings(2 ether);
    }

    function test_Receive_UpdatesBalance() public {
        vm.prank(alice);
        (bool ok,) = address(vault).call{value: 1 ether}("");
        assertTrue(ok);
        assertEq(vault.balance(alice), 1 ether);
    }

    function test_CheckBalance_ReturnsZeroForNewAddress() public view {
        assertEq(vault.checkIndividualBalances(alice), 0);
    }

    function testFuzz_DepositAndWithdraw(uint96 depositAmount, uint96 withdrawAmount) public {
        vm.assume(depositAmount > 0);
        vm.assume(withdrawAmount > 0 && withdrawAmount <= depositAmount);

        vm.deal(alice, depositAmount);
        vm.startPrank(alice);
        vault.depositToken{value: depositAmount}();
        vault.withdrawSavings(withdrawAmount);
        vm.stopPrank();

        assertEq(vault.balance(alice), depositAmount - withdrawAmount);
    }
}