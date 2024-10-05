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
    /**
     * @dev calculate amount of ETH user will recieve when selling X amount of tokens
     * ethAmount = oldSupply**2 - newSupply**2
     * newSupply = totalSupply - sellAmount
     * ethAmount = totalSupply**2 - (totalSupply - sellAmount)**2
     * @param _totalSupply of token
     * @param _sellAmount in tokens
     * @return ethAmount
     */
    function sellFor(
        uint256 _totalSupply,
        uint256 _sellAmount
    ) public pure returns (uint256 ethAmount) {
        uint256 newSupply = _totalSupply - _sellAmount;
        ethAmount = ((_totalSupply ** 2) - (newSupply ** 2));
    }

    /**
     * @dev calculate amount of token user will recieve when buying X amount of ETH
     * ethAmount = newSupply**2 - oldSupply**2
     * buyAmount = newSupply**2 - totalSupply**2
     * solve for newSupply
     * return newSupply - totalSupply
     * @param _totalSupply of token
     * @param _buyAmount in msg.value
     * @return tokenAmount
     */
    function buyFor(
        uint256 _totalSupply,
        uint256 _buyAmount
    ) public pure returns (uint256 tokenAmount) {
        uint256 newSupply = sqrt(_buyAmount + _totalSupply ** 2);
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
