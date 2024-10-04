// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Fees contract is used to calculate fees for buying and selling tokens
 * It is used by the factory contract
 */

contract Fee is Ownable {
    uint256 public FEE;

    constructor(address _owner) Ownable(_owner) {}

    /**
     * @dev owner can set the fee
     * @param _fee of 25 = 25%
     */
    function setFee(uint256 _fee) public onlyOwner {
        FEE = _fee;
    }

    /**
     * @dev calculate fee and remainder
     * @param _amount in tokens
     * @return [feeAmount, remainderAmount]
     **/
    function getAmount(
        uint256 _amount
    ) public view returns (uint256[2] memory) {
        uint256 feeAmount = (_amount * FEE) / 100;
        uint256 remainderAmount = _amount - feeAmount;
        return [feeAmount, remainderAmount];
    }
}
