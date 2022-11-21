// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Torch.sol";

contract TorchTest is Test {
    Torch public torch;

    address Alice = address(0x12345);
    address Bob = address(0x54321);

    uint256 initLightTime = block.timestamp;
    uint256 fuelPeriod = 100;

    function setUp() public {
        torch = new Torch(Alice, Bob, fuelPeriod);
        (bool success, ) = payable(torch).call{value: 1 ether}("");
        require(success, "TorchTest: failed to send ether to torch");
    }

    function testLight() public {
        assertEq(address(torch.owner()), Alice);
        assertEq(torch.beneficiary(), Bob);
        assertEq(torch.fuelPeriod(), fuelPeriod);
        assertEq(torch.lastFuelTime(), initLightTime);
    }

    function testFuel() public {
        vm.prank(Alice);
        torch.fuel();
        assertEq(torch.lastFuelTime(), block.timestamp);
    }

    function testFuelWithinFuelPeriod() public {
        vm.warp(block.timestamp + fuelPeriod);
        vm.prank(Alice);
        torch.fuel();
        assertEq(torch.lastFuelTime(), block.timestamp);
    }

    function testFuelAfterFuelPeriod() public {
        vm.warp(block.timestamp + fuelPeriod + 1);
        vm.prank(Alice);
        vm.expectRevert("Torch: the torch went out of fuel already");
        torch.fuel();
    }

    function testAliceWithdraw() public {
        vm.prank(Alice);
        torch.withdraw();
        assertEq(address(torch).balance, 0);
        assertEq(Alice.balance, 1 ether);
    }

    function testBobWithdraw() public {
        vm.prank(Bob);
        vm.expectRevert("Torch: the torch is still burning");
        torch.withdraw();
    }

    function testAliceWithdrawWhenBurning() public {
        vm.warp(block.timestamp + fuelPeriod);
        vm.prank(Alice);
        torch.fuel();

        vm.warp(block.timestamp + 1);
        vm.prank(Alice);
        torch.withdraw();

        assertEq(address(torch).balance, 0);
        assertEq(Alice.balance, 1 ether);
    }

    function testBobWithdrawWhenBurning() public {
        vm.warp(block.timestamp + fuelPeriod);
        vm.prank(Alice);
        torch.fuel();

        vm.warp(block.timestamp + 1);
        vm.prank(Bob);
        vm.expectRevert("Torch: the torch is still burning");
        torch.withdraw();
    }

    function testAliceWithdrawWhenBurnOut() public {
        vm.warp(block.timestamp + fuelPeriod);
        vm.prank(Alice);
        torch.fuel();

        vm.warp(block.timestamp + fuelPeriod + 1);
        vm.prank(Alice);
        vm.expectRevert("Torch: the torch went out of fuel already");
        torch.withdraw();
    }

    function testBobWithdrawWhenBurnOut() public {
        vm.warp(block.timestamp + fuelPeriod);
        vm.prank(Alice);
        torch.fuel();

        vm.warp(block.timestamp + fuelPeriod + 1);
        vm.prank(Bob);
        torch.withdraw();

        assertEq(address(torch).balance, 0);
        assertEq(Bob.balance, 1 ether);
    }
}
