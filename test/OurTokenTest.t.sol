// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test} from "forge-std/Test.sol";
import {DeployOurToken} from "script/DeployOurToken.s.sol";
import {OurToken} from "src/OurToken.sol";

contract OurTokenTest is Test {
    OurToken public ourToken;
    DeployOurToken public deployOurToken;

    // Make some addresses to play around with working with tokens
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployOurToken = new DeployOurToken();
        ourToken = deployOurToken.run();

        // The owner of token should be msg.sender, it is not the address of deployOurToken
        vm.prank(msg.sender);
        // We give bob 100 ether
        ourToken.transfer(bob, STARTING_BALANCE); // Transfer to bob
    }

    // Test balance of Bob
    function testBobBalance() public view {
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE);
    }

    // Test allowances
    function testAllowancesWorks() public {
        uint256 initialAllowance = 1000;

        // Bob approves Alice to spend tokens on her behalf
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        uint256 transferAmount = 500;

        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount); // We have to use transferFrom()
        // If we use transfer(), whoever is calling this transfer() funciton, will automatically set as the from
        // So the difference is transfer() automatically set the from as whoever is sending the msg
        // and transferFrom(), u can set anybody from, but it will only go through if they are approved

        assertEq(ourToken.balanceOf(alice), transferAmount);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }

    function testTransfer() public {
        uint256 transferAmount = 50 ether;
        vm.prank(bob);
        ourToken.transfer(alice, transferAmount);

        assertEq(ourToken.balanceOf(alice), transferAmount);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }
}
