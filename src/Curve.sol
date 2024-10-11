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
    int256 SLOPE; // slope
    int256 Y_INTERCEPT; // y intercept
    int256 DECIMALS; // DECIMALS

    constructor(int256 _slope, int256 _yIntercept, int256 _decimals) {
        SLOPE = _slope;
        Y_INTERCEPT = _yIntercept;
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
        require(_totalSupply >= 0, "totalSupply negative");
        require(_sellAmount >= 0, "sellAmount negative");
        int256 totalSupply = int256(_totalSupply) / DECIMALS;
        int256 sellAmount = int256(_sellAmount) / DECIMALS;
        int256 oldAUC = auc(totalSupply);
        int256 newSupply = totalSupply - sellAmount;
        int256 newAUC = auc(newSupply);
        int256 ethAmount = oldAUC - newAUC;
        require(ethAmount >= 0, "ethAmount negative");
        return uint256(ethAmount * DECIMALS);
    }

    /**
     * @dev calculate amount of token user will recieve when buying X amount of ETH
     * buyAmount =  newAUC - oldAUC
     * buyAmount = (SLOPE / 2 * newSupply * newSupply) + (Y_INTERCEPT * newSupply) - oldAUC
     * 0 = (SLOPE * newSupply^2) + (2 * Y_INTERCEPT * newSupply) + 2 * (oldAUC - buyAmount)
     * solve for newSupply (quardartic equation)
     * return newSupply - totalSupply
     * @param _totalSupply of token
     * @param _buyAmount in msg.value
     * @return tokenAmount
     */
    function buyFor(uint256 _totalSupply, uint256 _buyAmount) public view returns (uint256) {
        require(_totalSupply >= 0, "totalSupply negative");
        require(_buyAmount >= 0, "buyAmount negative");
        int256 totalSupply = int256(_totalSupply) / DECIMALS;
        int256 buyAmount = int256(_buyAmount) / DECIMALS;
        int256 oldAUC = auc(totalSupply);
        int256 A = SLOPE;
        int256 B = 2 * Y_INTERCEPT;
        int256 C = 2 * (oldAUC - buyAmount);
        // 0 = (-b ± √Δ) / 2a
        int256 delta = sqrt(abs(B * B - 4 * A * C));
        int256 newSupply = (-B + delta) / (2 * A);
        // return difference between new and old supply
        int256 tokenAmount = newSupply - totalSupply;
        require(tokenAmount >= 0, "tokenAmount negative");
        return uint256(tokenAmount * DECIMALS);
    }

    /**
     * @dev calculate area under curve
     * y = mx + b
     * m = slope
     * x = _supply
     * b = yIntercept
     * y = _supply * slope + yIntercept
     * auc = _supply**2 * slope / 2 + yIntercept * _supply
     * auc = ((_supply * _supply * SLOPE) / 2) + (Y_INTERCEPT * _supply)
     * @param _supply of token
     * @return area under the curve
     */
    function auc(int256 _supply) public view returns (int256) {
        require(_supply >= 0, "supply negative");
        int256 term1 = (_supply * _supply * SLOPE) / 2;
        int256 term2 = Y_INTERCEPT * _supply;
        int256 area = term1 + term2;
        require(area >= 0, "area negative");
        return area;
    }

    /**
     * @dev caculate the absolute value
     * @param x positive or negative value
     */
    function abs(int256 x) public pure returns (int256) {
        if (x < 0) {
            return int256(-x);
        } else {
            return int256(x);
        }
    }

    /**
     * @dev Uniswap method to find square root of a number
     * @dev https://github.com/Uniswap/v2-core/blob/v1.0.1/contracts/libraries/Math.sol
     * @param y number to find square root of
     */
    function sqrt(int256 y) public pure returns (int256 z) {
        require(y >= 0, "negative");
        if (y > 3) {
            z = y;
            int256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}
