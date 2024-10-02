// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./utils/Power.sol"; // Efficient power function.

/**
 * @title Bancor formula
 * @dev https://yos.io/2018/11/10/bonding-curves/
 */
contract Curve is Power {
    uint32 private constant MAX_RESERVE_RATIO = 1_000_000;

    /**
     * @dev depositing ETH to get tokens
     * @dev tokenAmount = _supply * ((1 + _buyAmount / _reserveBalance) ^ (_reserveRatio / MAX_RESERVE_RATIO) - 1)
     *
     * @param _supply continuous token total supply
     * @param _reserveBalance total reserve token balance
     * @param _reserveRatio reserve ratio, represented in ppm, 1-1000000
     * @param _buyAmount deposit amount, in reserve token
     *
     *  @return buy return amount
     */
    function buyFor(
        uint256 _supply,
        uint256 _reserveBalance,
        uint32 _reserveRatio,
        uint256 _buyAmount
    ) public view returns (uint256) {
        // validate input
        require(
            _supply > 0 &&
                _reserveBalance > 0 &&
                _reserveRatio > 0 &&
                _reserveRatio <= MAX_RESERVE_RATIO
        );
        // special case for 0 deposit amount
        if (_buyAmount == 0) {
            return 0;
        }
        // special case if the ratio = 100%
        if (_reserveRatio == MAX_RESERVE_RATIO) {
            return (_supply * _buyAmount) / _reserveBalance;
        }
        uint256 result;
        uint8 precision;
        uint256 baseN = _buyAmount + _reserveBalance;
        (result, precision) = power(
            baseN,
            _reserveBalance,
            _reserveRatio,
            MAX_RESERVE_RATIO
        );
        uint256 newTokenSupply = (_supply * result) >> precision;
        return newTokenSupply - _supply;
    }

    /**
     * @dev depositing tokens to get ETH
     * @dev ETHAmount = _reserveBalance * (1 - (1 - _sellAmount / _supply) ** (1 / (_reserveRatio / MAX_RESERVE_RATIO)))
     *
     * @param _supply continuous token total supply
     * @param _reserveBalance total reserve token balance
     * @param _reserveRatio constant reserve ratio, represented in ppm, 1-1000000
     * @param _sellAmount sell amount, in the continuous token itself
     *
     * @return sale return amount
     */
    function sellFor(
        uint256 _supply,
        uint256 _reserveBalance,
        uint32 _reserveRatio,
        uint256 _sellAmount
    ) public view returns (uint256) {
        // validate input
        require(
            _supply > 0 &&
                _reserveBalance > 0 &&
                _reserveRatio > 0 &&
                _reserveRatio <= MAX_RESERVE_RATIO &&
                _sellAmount <= _supply
        );
        // special case for 0 sell amount
        if (_sellAmount == 0) {
            return 0;
        }
        // special case for selling the entire supply
        if (_sellAmount == _supply) {
            return _reserveBalance;
        }
        // special case if the ratio = 100%
        if (_reserveRatio == MAX_RESERVE_RATIO) {
            return (_reserveBalance * _sellAmount) / _supply;
        }
        uint256 result;
        uint8 precision;
        uint256 baseD = _supply - _sellAmount;
        (result, precision) = power(
            _supply,
            baseD,
            MAX_RESERVE_RATIO,
            _reserveRatio
        );
        uint256 oldBalance = _reserveBalance * result;
        uint256 newBalance = _reserveBalance << precision;
        return (oldBalance - newBalance) / (result);
    }
}
