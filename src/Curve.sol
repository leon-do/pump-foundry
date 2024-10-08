// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/**
 * @title Bonding Curve
 * y = mx + b
 * y = price
 * m = SLOPE
 * x = supply
 * b = Y_INTERCEPT
 * ∫price = auc =  (m / 2 * x * x) - (b * x)
 */
contract Curve {
    uint256 SLOPE; // slope
    int256 Y_INTERCEPT; // y intercept

    constructor(uint256 _slope, int256 _yIntercept) {
        SLOPE = _slope;
        Y_INTERCEPT = _yIntercept;
    }

    /**
     * @dev calculate amount of ETH user will recieve when selling X amount of tokens
     * Area Under Curve (AUC) = supply**2 / SLOPE
     * ethAmount = oldAUC - newAUC
     * @param _totalSupply of token
     * @param _sellAmount in tokens
     * @return ethAmount
     */
    function sellFor(
        uint256 _totalSupply,
        uint256 _sellAmount
    ) public view returns (uint256 ethAmount) {
        uint256 oldAUC = auc(_totalSupply);
        uint256 newSupply = _totalSupply - _sellAmount;
        uint256 newAUC = auc(newSupply);
        ethAmount = oldAUC - newAUC;
    }

    /**
     * @dev calculate amount of token user will recieve when buying X amount of ETH
     * buyAmount =  newAUC - oldAUC
     * auc = ((_supply * _supply * SLOPE) / 2) - (Y_INTERCEPT * _supply)
     * buyAmount = (((_supply * newSupply * SLOPE) / 2) - (Y_INTERCEPT * newSupply)) - oldAUC
     * solve for newSupply
     * return newSupply - oldSupply
     * @param _totalSupply of token
     * @param _buyAmount in msg.value
     * @return tokenAmount
     */
    function buyFor(
        uint256 _totalSupply,
        uint256 _buyAmount
    ) public view returns (uint256 tokenAmount) {
        uint256 oldAUC = auc(_totalSupply);
        // Coefficients for the quadratic equation
        uint256 A = SLOPE;
        int256 B = 2 * Y_INTERCEPT;
        uint256 C = 2 * (oldAUC + _buyAmount);
        // Discriminant: B^2 + 4 * A * C (no negative signs as we're using uint256)
        uint256 discriminant = uint256(B * B) + 4 * A * C;
        // Calculate the square root of the discriminant
        uint256 sqrtDiscriminant = sqrt(discriminant);
        // Ensure B is converted to uint256 safely
        require(sqrtDiscriminant >= uint256(B), "underflow");
        // Using the quadratic formula: (-B + sqrt(discriminant)) / 2A
        uint256 newSupply = (sqrtDiscriminant - uint256(B)) / (2 * A);
        // return difference between new and old supply
        tokenAmount = (newSupply - _totalSupply);
    }

    /**
     * @dev calculate area under curve
     * auc = ((_supply * _supply * SLOPE) / 2) - (Y_INTERCEPT * _supply)
     * @param _supply of token
     */
    function auc(uint256 _supply) public view returns (uint256) {
        uint256 term1 = (_supply * _supply * SLOPE) / 2;
        int256 term2 = int256(Y_INTERCEPT) * int256(_supply);
        require(term1 >= uint256(term2), "underflow");
        return term1 - uint256(term2);
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
