// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./Token.sol";
import "./Curve.sol";

/**
 * @title Factory contract is the main entry point for users to create, buy, and sell tokens.
 */
contract Factory {
    Curve curve = new Curve();

    constructor() {}

    /**
     * @dev anyone can create tokens
     * @param _name of token
     * @param _symbol of token
     * @param _reserveRatio for the shape of the bonding curve (500_000 == 50%)
     * @param _dexSupply of tokens to trigger deposit to DEX
     * @return address of token
     */
    function create(
        string memory _name,
        string memory _symbol,
        uint32 _reserveRatio,
        uint256 _dexSupply
    ) public returns (address) {
        Token newToken = new Token(
            _name,
            _symbol,
            address(this),
            _reserveRatio,
            _dexSupply
        );
        newToken.mint(address(newToken), 10 * 18);
        return address(newToken);
    }

    /**
     * @dev depositing ETH to get tokens
     * @param _token token address
     */
    function buy(address _token) public payable {
        uint256 amount = buyFor(_token, msg.value);
        Token(payable(_token)).mint(msg.sender, amount);
    }

    /**
     * @dev deposit tokens to get ETH
     * @param _token token address
     * @param _sellAmount in tokens to sell
     */
    function sell(address _token, uint256 _sellAmount) public payable {
        Token(_token).burn(msg.sender, _sellAmount);
        // calculate ether amount
        uint256 etherAmount = sellFor(_token, _sellAmount);
        // return ether
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
        uint256 reserveBalance = address(this).balance;
        uint32 reserveRatio = Token(_token).RESERVE_RATIO();
        tokenAmount = curve.buyFor(
            totalSupply,
            reserveBalance,
            reserveRatio,
            _buyAmount
        );
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
        uint256 reserveBalance = address(this).balance;
        uint32 reserveRatio = Token(_token).RESERVE_RATIO();
        ethAmount = curve.sellFor(
            totalSupply,
            reserveBalance,
            reserveRatio,
            _sellAmount
        );
    }
}
