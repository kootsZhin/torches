// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interface/ITorches.sol";
import "./Torch.sol";

contract Torches is ITorches {
    /**
     * @dev Create a new 'torch'.
     */
    function light(
        address owner,
        address beneficiary,
        uint256 fuelPeriod
    ) external payable returns (address torch) {
        torch = address(new Torch(owner, beneficiary, fuelPeriod));

        (bool success, ) = torch.call{value: msg.value}("");
        require(success, "Torches: failed to send ether to torch");

        emit Light(owner, beneficiary, fuelPeriod, block.timestamp);
    }
}
