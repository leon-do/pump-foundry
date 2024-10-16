// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./Token.sol";
import "./Curve.sol";
import "./Fee.sol";

/**
 * @title Factory contract is the main entry point for users to create, buy, and sell tokens.
 */
contract Factory {
    Curve curve;
    Fee fee;

    constructor() {
        curve = new Curve(1, 10 ** 30);
        fee = new Fee(msg.sender);
    }

    /**
     * @dev anyone can create tokens
     * @param _name of token
     * @param _symbol of token
     * @return address of token
     */
    function create(string memory _name, string memory _symbol) public returns (address) {
        Token newToken = new Token(_name, _symbol, address(this));
        newToken.mint(address(newToken), 1);
        return address(newToken);
    }

    /**
     * @dev deposit ETH to get tokens (aka mint)
     * @param _token token address
     */
    function buy(address _token) public payable returns (uint256 tokenAmount) {
        uint256 totalSupply = Token(_token).totalSupply();
        uint256 buyAmount = msg.value;
        // calculate token amount send to user
        tokenAmount = curve.buyFor(totalSupply, buyAmount);
        // mint tokens to user
        Token(payable(_token)).mint(msg.sender, tokenAmount);
    }

    /**
     * @dev deposit tokens to get ETH
     * @param _token token address
     * @param _sellAmount in tokens to sell
     */
    function sell(address _token, uint256 _sellAmount) public payable returns (uint256) {
        uint256 totalSupply = Token(_token).totalSupply();
        // calculate ether amount to send to user
        uint256 etherAmount = curve.sellFor(totalSupply, _sellAmount);
        uint256 feeAmount = fee.getAmount(etherAmount);
        uint256 userAmount = etherAmount - feeAmount;
        // burn tokens from user
        Token(_token).burn(msg.sender, _sellAmount);
        // send ether
        (bool feeSuccess,) = address(fee.owner()).call{value: feeAmount}("");
        require(feeSuccess, "Fee Transfer failed");
        (bool userSuccess,) = address(msg.sender).call{value: userAmount}("");
        require(userSuccess, "User Transfer failed");
        return userAmount;
    }
}
