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
    uint256 private constant MULTIPLIER = 1;
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
        uint256 oldAUC = auc(_totalSupply);
        uint256 newSupply = _totalSupply - _sellAmount;
        uint256 newAUC = auc(newSupply);
        ethAmount = oldAUC - newAUC;
    }

    /**
     * @dev calculate amount of token user will recieve when buying X amount of ETH
     * buyAmount =  newAUC - oldAUC
     * auc = ((_supply * _supply * MULTIPLIER) / 2) - (MINIMUM * _supply)
     * buyAmount = (((_supply * newSupply * MULTIPLIER) / 2) - (MINIMUM * newSupply)) - oldAUC
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
        uint256 oldAUC = auc(_totalSupply);
        // Coefficients for the quadratic equation
        uint256 A = MULTIPLIER;
        uint256 B = 2 * MINIMUM;
        uint256 C = 2 * (oldAUC + _buyAmount);
        // Discriminant: B^2 + 4 * A * C (no negative signs as we're using uint256)
        uint256 discriminant = B * B + 4 * A * C;
        // Calculate the square root of the discriminant
        uint256 sqrtDiscriminant = sqrt(discriminant);
        // Using the quadratic formula: (-B + sqrt(discriminant)) / 2A
        uint256 newSupply = (sqrtDiscriminant - B) / (2 * A);
        // return difference between new and old supply
        tokenAmount = (newSupply - _totalSupply);
    }

    /**
     * @dev calculate area under curve
     * @param _supply of token
     */
    function auc(uint256 _supply) public pure returns (uint256) {
        return ((_supply * _supply * MULTIPLIER) / 2) - (MINIMUM * _supply);
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
