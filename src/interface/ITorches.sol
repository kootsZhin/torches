// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface ITorches {
    /**
     * @dev Emitted when a new 'torch' is crated.
     */
    event Light(
        address indexed owner,
        address indexed beneficiary,
        uint256 fuelPeriod,
        uint256 lightTime
    );

    /**
     * @dev Create a new 'torch'.
     */
    function light(
        address owner,
        address beneficiary,
        uint256 fuelPeriod
    ) external payable returns (address torch);
}
