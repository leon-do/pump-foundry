// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./Token.sol";
import "./Curve.sol";

contract Factory {
    Curve curve = new Curve();

    constructor() {}

    /**
     * @dev create token
     * @param _name of token
     * @param _symbol of token
     * @return address of token
     */
    function create(string memory _name, string memory _symbol) public returns (address) {
        Token newToken = new Token(_name, _symbol, address(this));
        newToken.mint(address(this), 1);
        return address(newToken);
    }

    /**
     * @dev buy ETH to get tokens
     * @param _token token address
     */
    function buy(address _token) public payable {
        uint256 amount = buyFor(_token, msg.value);
        Token(payable(_token)).mint(msg.sender, amount);
    }

    /**
     * @dev sell tokens to get ETH
     * @param _token token address
     * @param _sellAmount in tokens to sell
     */
    function sell(address _token, uint256 _sellAmount) public payable {
        Token(_token).burn(msg.sender, _sellAmount);
        // calculate ether amount
        uint256 etherAmount = sellFor(_token, _sellAmount);
        // return ether
        (bool success,) = address(msg.sender).call{value: etherAmount}("");
        require(success, "Transfer failed");
    }

    /**
     * @dev calculate token amount
     * @param _token token address
     * @param _depositAmount in ETH
     * @return tokenAmount
     */
    function buyFor(address _token, uint256 _depositAmount) public view returns (uint256) {
        uint256 supply = Token(_token).totalSupply();
        uint256 reserveBalance = Token(_token).balanceOf(address(this));
        uint32 reserveRatio = 500000;
        return curve.buyFor(supply, reserveBalance, reserveRatio, _depositAmount);
    }

    /**
     * @dev calculate ETH amount
     * @param _token address
     * @param _sellAmount in tokens
     * @return ethAmount
     */
    function sellFor(address _token, uint256 _sellAmount) public view returns (uint256) {
        uint256 supply = Token(_token).totalSupply();
        uint256 reserveBalance = Token(_token).balanceOf(address(this));
        uint32 reserveRatio = 500000;
        return curve.sellFor(supply, reserveBalance, reserveRatio, _sellAmount);
    }
}
