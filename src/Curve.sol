// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/**
 * @title Bonding Curve
 * y = mx
 * y = price
 * m = SLOPE
 * x = supply
 * ∫price = auc =  (m / 2 * x * x)
 */
contract Curve {
    uint256 SLOPE_NUMERATOR;
    uint256 SLOPE_DENOMINATOR;
    uint256 DECIMALS; // DECIMALS

    constructor(uint256 _slopeNumerator, uint256 _slopeDenominator, uint256 _decimals) {
        SLOPE_NUMERATOR = _slopeNumerator;
        SLOPE_DENOMINATOR = _slopeDenominator;
        DECIMALS = _decimals;
    }

    /**
     * @dev calculate amount of ETH user will recieve when selling X amount of tokens
     * Area Under Curve (AUC) = supply**2 / SLOPE
     * ethAmount = oldAUC - newAUC
     * @param _totalSupply of token
     * @param _sellAmount in tokens
     * @return ethAmount
     */
    function sellFor(uint256 _totalSupply, uint256 _sellAmount) public view returns (uint256) {
        uint256 totalSupply = _totalSupply / DECIMALS;
        uint256 sellAmount = _sellAmount / DECIMALS;
        uint256 oldAUC = auc(totalSupply);
        uint256 newSupply = totalSupply - sellAmount;
        uint256 newAUC = auc(newSupply);
        uint256 ethAmount = oldAUC - newAUC;
        return ethAmount * DECIMALS;
    }

    /**
     * @dev calculate amount of token user will recieve when buying X amount of ETH
     * buyAmount =  newAUC - oldAUC
     * buyAmount = ((newSupply * newSupply * SLOPE) / 2) - oldAUC
     * newSupply = sqrt((2 / SLOPE * (buyAmount + oldAUC)))
     * return newSupply - totalSupply
     * @param _totalSupply of token
     * @param _buyAmount in msg.value
     * @return tokenAmount
     */
    function buyFor(uint256 _totalSupply, uint256 _buyAmount) public view returns (uint256) {
        uint256 totalSupply = _totalSupply / DECIMALS;
        uint256 buyAmount = _buyAmount / DECIMALS;
        uint256 oldAUC = auc(totalSupply);
        // solve for newSupply
        uint256 newSupply = sqrt((((2 * SLOPE_DENOMINATOR) / SLOPE_NUMERATOR) * (buyAmount + oldAUC)));
        // return difference between new and old supply
        uint256 tokenAmount = newSupply - totalSupply;
        return tokenAmount * DECIMALS;
    }

    /**
     * @dev calculate area under curve
     * y = mx
     * m = slope
     * x = _supply
     * y =  slope * _supply
     * auc = _supply**2 * slope / 2
     * auc = ((_supply * _supply * SLOPE) / 2) + (Y_INTERCEPT * _supply)
     * @param _supply of token
     * @return area under the curve
     */
    function auc(uint256 _supply) public view returns (uint256) {
        return (_supply * _supply * SLOPE_NUMERATOR) / SLOPE_DENOMINATOR / 2;
    }

    /**
     * @dev Uniswap method to find square root of a number
     * @dev https://github.com/Uniswap/v2-core/blob/v1.0.1/contracts/libraries/Math.sol
     * @param y number to find square root of
     */
    function sqrt(uint256 y) public pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}
