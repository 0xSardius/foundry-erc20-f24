// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";

contract OurTokenTest is Test {
    OurToken public ourToken;
    DeployOurToken public deployer;

    address bob = makeAddr("Bob");
    address alice = makeAddr("Alice");

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        vm.prank(msg.sender);
        ourToken.transfer(bob, STARTING_BALANCE);
    }

    function testBobBalance() public view {
        assertEq(STARTING_BALANCE, ourToken.balanceOf(bob));
    }
    
    function testAllowancesWorks() public {
        uint256 initialAllowance = 100 ether;

        // Bob approves Alice to spend 100 ether
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        uint256 transferAmount = 50 ether;

        // Alice tries to transfer 50 ether from Bob
        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);

        assertEq(ourToken.balanceOf(alice), transferAmount);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }

    function testTransferWithoutAllowance() public {
        // Attempt to transfer without allowance
        vm.prank(alice);
        vm.expectRevert();
        ourToken.transferFrom(bob, alice, 1 ether);
    }

    // function testIncreaseAllowance() public {
    //     uint256 initialAllowance = 100 ether;
    //     uint256 increaseAmount = 50 ether;

    //     vm.prank(bob);
    //     ourToken.approve(alice, initialAllowance);

    //     vm.prank(bob);
    //     bool success = ourToken.increaseAllowance(alice, increaseAmount);

    //     assertTrue(success, "Increase allowance should succeed");
    //     assertEq(ourToken.allowance(bob, alice), initialAllowance + increaseAmount, "Allowance not increased correctly");
    // }

    // function testDecreaseAllowance() public {
    //     uint256 initialAllowance = 100 ether;
    //     uint256 decreaseAmount = 30 ether;

    //     vm.prank(bob);
    //     ourToken.approve(alice, initialAllowance);

    //     vm.prank(bob);
    //     bool success = ourToken.decreaseAllowance(alice, decreaseAmount);

    //     assertTrue(success, "Decrease allowance should succeed");
    //     assertEq(ourToken.allowance(bob, alice), initialAllowance - decreaseAmount, "Allowance not decreased correctly");
    // }

    function testTransferToZeroAddress() public {
        vm.prank(bob);
        vm.expectRevert();
        ourToken.transfer(address(0), 1 ether);
    }

    function testApproveToZeroAddress() public {
        vm.prank(bob);
        vm.expectRevert();
        ourToken.approve(address(0), 1 ether);
    }

    function testTransferMoreThanBalance() public {
        vm.prank(bob);
        vm.expectRevert();
        ourToken.transfer(alice, STARTING_BALANCE + 1 ether);
    }

    function testAllowanceDoesNotChangeOnFailedTransfer() public {
        uint256 allowance = 100 ether;
        vm.prank(bob);
        ourToken.approve(alice, allowance);

        vm.prank(alice);
        vm.expectRevert();
        ourToken.transferFrom(bob, alice, STARTING_BALANCE + 1 ether);

        assertEq(ourToken.allowance(bob, alice), allowance, "Allowance should not change on failed transfer");
    }
}
