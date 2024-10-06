// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./Token.sol";
import "./Curve.sol";
import "./Fee.sol";

/**
 * @title Factory contract is the main entry point for users to create, buy, and sell tokens.
 */
contract Factory {
    mapping(address => uint256) public reserveBalances;
    Curve curve = new Curve();
    Fee fee;

    constructor() {
        fee = new Fee(msg.sender);
    }

    /**
     * @dev anyone can create tokens
     * @param _name of token
     * @param _symbol of token
     * @return address of token
     */
    function create(
        string memory _name,
        string memory _symbol,
        uint32 _reserveRatio
    ) public returns (address) {
        Token newToken = new Token(
            _name,
            _symbol,
            address(this),
            _reserveRatio
        );
        newToken.mint(address(newToken), 1);
        return address(newToken);
    }

    /**
     * @dev deposit ETH to get tokens (aka mint)
     * @param _token token address
     */
    function buy(address _token) public payable returns (uint256 tokenAmount) {
        uint256 totalSupply = Token(_token).totalSupply();
        uint256 reserveBalance = reserveBalances[_token] > 0
            ? reserveBalances[_token]
            : 1;
        uint32 reserveRatio = Token(_token).reserveRatio();
        uint256 buyAmount = msg.value;
        // calculate token amount send to user
        tokenAmount = curve.buyFor(
            totalSupply,
            reserveBalance,
            reserveRatio,
            buyAmount
        );
        // update reserve balance
        reserveBalances[_token] += buyAmount;
        // mint tokens to user
        Token(payable(_token)).mint(msg.sender, tokenAmount);
    }

    /**
     * @dev deposit tokens to get ETH
     * @param _token token address
     * @param _sellAmount in tokens to sell
     */
    function sell(
        address _token,
        uint256 _sellAmount
    ) public payable returns (uint256 etherAmount) {
        uint256 totalSupply = Token(_token).totalSupply();
        uint256 reserveBalance = reserveBalances[_token];
        uint32 reserveRatio = Token(_token).reserveRatio();
        // calculate ether amount to send to user
        etherAmount = curve.sellFor(
            totalSupply,
            reserveBalance,
            reserveRatio,
            _sellAmount
        );
        // burn tokens from user
        Token(_token).burn(msg.sender, _sellAmount);
        // update reserve balance
        reserveBalances[_token] -= etherAmount;
        // send ether to user
        (bool success, ) = address(msg.sender).call{value: etherAmount}("");
        require(success, "Transfer failed");
    }
}
