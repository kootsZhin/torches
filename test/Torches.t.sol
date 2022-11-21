pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Torch.sol";
import "../src/Torches.sol";

contract CreateTorchesTest is Test {
    Torches public torches;

    address Alice = address(0x12345);
    address Bob = address(0x54321);

    uint256 initLightTime = block.timestamp;

    function setUp() public {
        torches = new Torches();
    }

    function testCreateTorch(uint8 amount, uint8 _fuelPeriod) public {
        address t = torches.light{value: amount}(Alice, Bob, _fuelPeriod);

        Torch torch = Torch(payable(t));

        assertEq(address(torch.owner()), Alice);
        assertEq(torch.beneficiary(), Bob);
        assertEq(torch.fuelPeriod(), _fuelPeriod);
        assertEq(torch.lastFuelTime(), initLightTime);

        assertEq(address(torch).balance, amount);
        assertEq(address(torches).balance, 0);
    }
}

contract TorchesTest is Test {
    Torches public torches;
    Torch public torch;

    address Alice = address(0x12345);
    address Bob = address(0x54321);

    uint256 initLightTime = block.timestamp;
    uint256 fuelPeriod = 100;

    function setUp() public {
        torches = new Torches();
        address t = torches.light{value: 1 ether}(Alice, Bob, fuelPeriod);
        torch = Torch(payable(t));
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
