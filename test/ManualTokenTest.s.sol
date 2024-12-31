// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test} from "forge-std/Test.sol";
import {ManualToken} from "src/ManualToken.sol";
import {DeployManualToken} from "script/DeployManualToken.s.sol";
import {console2} from "forge-std/console2.sol";

contract ManualTokenTest is Test {
    ManualToken public manualToken;
    DeployManualToken public deployManualToken;

    // Make some addresses to play around with working with tokens
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployManualToken = new DeployManualToken();
        manualToken = deployManualToken.run();

        // The owner of token should be msg.sender
        vm.prank(msg.sender);

        // We give bob 100 ether
        manualToken.transfer(bob, STARTING_BALANCE); // Transfer to bob
    }

    // Test balance of Bob
    function testBobBalance() public view {
        assertEq(manualToken.balanceOf(bob), STARTING_BALANCE);
    }

    function testTransfer() public {
        uint256 transferAmount = 50 ether;
        vm.prank(bob);
        manualToken.transfer(alice, transferAmount);

        assertEq(manualToken.balanceOf(alice), transferAmount);
        assertEq(manualToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }

    function testDecimal() public view {
        assertEq(manualToken.balanceOf(bob) / 10 ** manualToken.decimals(), 100);
    }

    function testTotalSupply() public view {
        assertEq(manualToken.totalSupply(), 1000 ether);
    }

    function testTransferExpectRevert() public {
        uint256 transferAmount = 500 ether;
        vm.prank(bob);
        vm.expectRevert(ManualToken.ManualToken__TransferInsufficientBalance.selector);
        manualToken.transfer(alice, transferAmount);
    }

    function testAprroveAllowances() public {
        uint256 approveAllowance = 50 ether;

        vm.prank(bob);
        manualToken.approve(alice, approveAllowance);

        uint256 allowancesApproved = manualToken.allowance(bob, alice);

        assertEq(approveAllowance, allowancesApproved);
    }

    function testAllowancesWorks() public {
        uint256 approveAllowance = 50 ether;

        vm.prank(bob);
        manualToken.approve(alice, approveAllowance);

        uint256 transferAmount = 40 ether;

        vm.prank(alice);
        manualToken.transferFrom(bob, alice, transferAmount);

        uint256 remainingAllowance = manualToken.allowance(bob, alice);

        assertEq(manualToken.balanceOf(alice), transferAmount);
        assertEq(remainingAllowance, approveAllowance - transferAmount);
    }

    function testTransferFromRevertInsufficientAllowance() public {
        uint256 approveAllowance = 50 ether;

        vm.prank(bob);
        manualToken.approve(alice, approveAllowance);

        uint256 transferAmount = 60 ether;

        vm.prank(alice);
        vm.expectRevert(ManualToken.ManualToken__TransferFromInsufficientAllowance.selector);
        manualToken.transferFrom(bob, alice, transferAmount);
    }

    function testBurn() public {
        vm.prank(bob);
        manualToken.burn(address(0), 30 ether);

        assertEq(manualToken.totalSupply(), 970 ether);
        assertEq(manualToken.balanceOf(bob), 70 ether);
    }

    function testBurnRevertWrongBurnAddress() public {
        vm.prank(bob);
        vm.expectRevert(ManualToken.ManualToken__WrongBurnAddress.selector);
        manualToken.burn(alice, 30 ether);
    }

    function testBurnRevertIssuficientBalance() public {
        vm.prank(bob);
        vm.expectRevert(ManualToken.ManualToken__BurnInsufficientBalance.selector);
        manualToken.burn(address(0), 110 ether);
    }

    function testMint() public {
        vm.prank(bob);
        manualToken.mint(bob, 30 ether);

        assertEq(manualToken.totalSupply(), 1030 ether);
        assertEq(manualToken.balanceOf(bob), 100 ether + 30 ether);
    }

    function testName() public view {
        assertEq(manualToken.name(), "Manual Token");
    }

    function testSymbol() public view {
        assertEq(manualToken.symbol(), "MT");
    }
}
