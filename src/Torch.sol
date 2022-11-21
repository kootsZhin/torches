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
     * @dev The constructor 'lights' the 'torch' contract.
     */
    constructor(
        address owner_,
        address beneficiary_,
        uint256 fuelPeriod_
    ) {
        if (owner_ != msg.sender) transferOwnership(owner_);

        _beneficiary = beneficiary_;
        _fuelPeriod = fuelPeriod_;
        _lastFuelTime = block.timestamp;

        emit Light(address(owner()), _beneficiary, _fuelPeriod, _lastFuelTime);
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

    function fuel() external onlyOwner {
        require(
            block.timestamp - _lastFuelTime <= _fuelPeriod,
            "Torch: the torch went out of fuel already"
        );

        _lastFuelTime = block.timestamp;

        emit Fuel(address(owner()), _beneficiary, _lastFuelTime);
    }

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
            (bool success, ) = payable(owner()).call{
                value: address(this).balance
            }("");
            require(success, "Withdraw failed");
        }

        if (msg.sender == _beneficiary) {
            require(
                block.timestamp - _lastFuelTime > _fuelPeriod,
                "Torch: the torch is still burning"
            );
            (bool success, ) = payable(_beneficiary).call{
                value: address(this).balance
            }("");
            require(success, "Withdraw failed");
        }
    }

    receive() external payable {}
}
