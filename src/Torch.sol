// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interface/ITorch.sol";

contract Torch is ITorch, Ownable {
    /**
     * @dev The 'beneficiary' is the address that can withdraw ethers from the 'torch' contract when it goes out.
     */
    address private immutable _beneficiary;

    /**
     * @dev The 'fuelPeriod' is the time period that the 'owner' has to 'fuel' the 'torch' to keep it burning. (in seconds)
     */
    uint256 private immutable _fuelPeriod;

    /**
     * @dev The 'lastFuelTime' is the timestamp of the last time the 'owner' 'fuel' the 'torch'.
     */
    uint256 private _lastFuelTime;

    /**
     * @dev The 'lightTime' is the timestamp of the time when the 'torch' was initially lighted.
     */
    uint256 private _lightTime;

    /**
     * @dev The constructor 'lights' the 'torch' contract.
     */
    constructor(
        address owner_,
        address beneficiary_,
        uint256 fuelPeriod_
    ) {
        require(owner_ != beneficiary_, "Torch: owner is the beneficiary");
        require(owner_ != address(0), "Torch: owner is the zero address");
        require(
            beneficiary_ != address(0),
            "Torch: beneficiary is the zero address"
        );

        if (owner_ != msg.sender) transferOwnership(owner_);

        _beneficiary = beneficiary_;
        _fuelPeriod = fuelPeriod_;
        _lastFuelTime = block.timestamp;
        _lightTime = _lastFuelTime;
    }

    function beneficiary() public view returns (address) {
        return _beneficiary;
    }

    function fuelPeriod() public view returns (uint256) {
        return _fuelPeriod;
    }

    function lastFuelTime() public view returns (uint256) {
        return _lastFuelTime;
    }

    function lightTime() public view returns (uint256) {
        return _lightTime;
    }

    /**
     * @dev 'Owner' has to 'fuel' the 'torch' every 'fuelPeriod' to keep it burning.
     */
    function fuel() external onlyOwner {
        require(
            block.timestamp - _lastFuelTime <= _fuelPeriod,
            "Torch: the torch went out of fuel already"
        );

        _lastFuelTime = block.timestamp;

        emit Fuel(address(owner()), _beneficiary, _lastFuelTime);
    }

    /**
     * @dev 'Owner' can 'withdraw' ethers from the 'torch' contract when it is burning,
     *'beneficiary' can 'withdraw' ethers from the 'torch' contract when it burns out.
     */
    function withdraw() external {
        require(
            msg.sender == address(owner()) || msg.sender == _beneficiary,
            "Torch: only owner or beneficiary can withdraw"
        );

        if (msg.sender == address(owner())) {
            require(
                block.timestamp - _lastFuelTime <= _fuelPeriod,
                "Torch: the torch went out of fuel already"
            );
        } else {
            require(
                block.timestamp - _lastFuelTime > _fuelPeriod,
                "Torch: the torch is still burning"
            );
        }

        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");

        require(success, "Withdraw failed");
    }

    /**
     * @dev The contract is payable
     */
    receive() external payable {}
}
