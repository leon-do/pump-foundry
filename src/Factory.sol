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
        string memory _symbol
    ) public returns (address) {
        Token newToken = new Token(_name, _symbol, address(this));
        newToken.mint(address(newToken), 10 * 18);
        return address(newToken);
    }

    /**
     * @dev deposit ETH to get tokens
     * @param _token token address
     */
    function buy(address _token) public payable {
        // calculate token amount send to user
        uint256 tokenAmount = buyFor(_token, msg.value);
        // update reserve balance
        reserveBalances[_token] += msg.value;
        // mint tokens to user
        Token(payable(_token)).mint(msg.sender, tokenAmount);
    }

    /**
     * @dev deposit tokens to get ETH
     * @param _token token address
     * @param _sellAmount in tokens to sell
     */
    function sell(address _token, uint256 _sellAmount) public payable {
        // burn tokens from user
        Token(_token).burn(msg.sender, _sellAmount);
        // calculate ether amount to send to user
        uint256 etherAmount = sellFor(_token, _sellAmount);
        // update reserve balance
        reserveBalances[_token] -= etherAmount;
        // send ether to user
        (bool success, ) = address(msg.sender).call{value: etherAmount}("");
        require(success, "Transfer failed");
    }

    /**
     * @dev buying X amount in ETH will give Y token amount of tokens
     * @param _token token address
     * @param _buyAmount in ETH
     * @return tokenAmount
     */
    function buyFor(
        address _token,
        uint256 _buyAmount
    ) public view returns (uint256 tokenAmount) {
        uint256 totalSupply = Token(_token).totalSupply();
        uint256 reserveBalance = reserveBalances[_token];
        uint32 reserveRatio = 500_000;
        tokenAmount = curve.buyFor(totalSupply, reserveBalance, reserveRatio, _buyAmount);
    }

    /**
     * @dev selling X amount of tokens will give Y amount of ETH
     * @param _token address
     * @param _sellAmount in tokens
     * @return ethAmount
     */
    function sellFor(
        address _token,
        uint256 _sellAmount
    ) public view returns (uint256 ethAmount) {
        uint256 totalSupply = Token(_token).totalSupply();
        uint256 reserveBalance = reserveBalances[_token];
        uint32 reserveRatio = 500_000;
        ethAmount = curve.sellFor(totalSupply, reserveBalance, reserveRatio, _sellAmount);
    }
}
