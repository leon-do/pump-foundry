// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// Bonding Curve based on a square root curve y = m * (x ^ 1/2)
// This bonding curve is equivalent to Bancor's Formula where reserve ratio = 2/3
contract Curve {
    uint256 public constant DECIMALS = 10 ** 18;

    /**
     * @dev https://ipfs.io/ipfs/QmZUHR5kjxyERb1v1vUtkFCf9ruYD41KjzRJ5qr4h4D4uL
     * @param _totalSupply of token
     * @param _reserveBalance in ETH
     * @param _buyAmount in ETH
     */
    function buyFor(
        uint256 _totalSupply,
        uint256 _reserveBalance,
        uint256 _buyAmount
    ) public pure returns (uint256) {
        uint256 newTotal = _totalSupply + _buyAmount;
        uint256 newPrice = ((newTotal * newTotal) / DECIMALS) *
            (newTotal / DECIMALS);
        return (sqrt(newPrice) * 2) / 3 - _reserveBalance;
    }

    /**
     * @dev https://ipfs.io/ipfs/QmSHqTuTz8ygYnx8UnU7z3go7jmxhLR9TmVQm2E8VKTdpA
     * @param _totalSupply of token
     * @param _reserveBalance in ETH
     * @param _sellAmount in tokens
     */
    function sellFor(
        uint256 _totalSupply,
        uint256 _reserveBalance,
        uint256 _sellAmount
    ) public pure returns (uint256) {
        uint256 newTotal = _totalSupply - _sellAmount;
        uint256 newPrice = ((newTotal * newTotal) / DECIMALS) *
            (newTotal / DECIMALS);
        return _reserveBalance - (sqrt(newPrice) * 2) / 3;
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
