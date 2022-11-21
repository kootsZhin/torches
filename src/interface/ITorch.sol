// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface ITorch {
    /**
     * @dev Emitted when 'owner' execute the 'fuel' function of the 'torch'.
     */
    event Fuel(
        address indexed owner,
        address indexed beneficiary,
        uint256 fuelTime
    );

    /**
     * @dev 'Owner' has to 'fuel' the 'torch' every 'fuelPeriod' to keep it burning.
     */
    function fuel() external;

    /**
     * @dev 'Owner' can 'withdraw' ethers from the 'torch' contract when it is burning,
     *'beneficiary' can 'withdraw' ethers from the 'torch' contract when it burns out.
     */
    function withdraw() external;

    /**
     * @dev The contract is payable
     */
    receive() external payable;
}
