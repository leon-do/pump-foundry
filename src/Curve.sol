// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/**
 * @title Bonding Curve
 * y = 2x
 * y = price
 * x = supply
 * price = 2 * supply
 * ∫price = totalPrice = supply**2
 */
contract Curve {
    uint256 private constant MULTIPLIER = 2;
    uint256 private constant MINIMUM = 0; // y intercept

    /**
     * @dev calculate amount of ETH user will recieve when selling X amount of tokens
     * Area Under Curve (AUC) = supply**2 / MULTIPLIER
     * ethAmount = oldAUC - newAUC
     * @param _totalSupply of token
     * @param _sellAmount in tokens
     * @return ethAmount
     */
    function sellFor(
        uint256 _totalSupply,
        uint256 _sellAmount
    ) public pure returns (uint256 ethAmount) {
        uint256 oldAUC = (_totalSupply * _totalSupply) / MULTIPLIER;
        uint256 newSupply = _totalSupply - _sellAmount;
        uint256 newAUC = (newSupply * newSupply) / MULTIPLIER;
        ethAmount = oldAUC - newAUC;
    }

    /**
     * @dev calculate amount of token user will recieve when buying X amount of ETH
     * Area Under Curve (AUC) = supply**2 / MULTIPLIER
     * buyAmount =  newAUC - oldAUC
     * buyAmount = (newSupply**2 / MULTIPLIER) - oldAUC
     * solve for newSupply
     * return newSupply - oldSupply
     * @param _totalSupply of token
     * @param _buyAmount in msg.value
     * @return tokenAmount
     */
    function buyFor(
        uint256 _totalSupply,
        uint256 _buyAmount
    ) public pure returns (uint256 tokenAmount) {
        uint256 oldAUC = (_totalSupply * _totalSupply) / MULTIPLIER;
        uint256 newSupply = sqrt((_buyAmount + oldAUC) * MULTIPLIER);
        tokenAmount = (newSupply - _totalSupply);
    }

    /**
     * @dev Uniswap method to find square root of a number
     * @dev https://github.com/Uniswap/v2-core/blob/v1.0.1/contracts/libraries/Math.sol
     * @param y number to find square root of
     */
    function sqrt(uint y) public pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}
