// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./Token.sol";

contract Factory {
    constructor() payable {}
    receive() external payable {}
    fallback() external payable {}

    function create(
        string memory _name,
        string memory _symbol
    ) public returns (address) {
        Token newToken = new Token(_name, _symbol, address(this));
        return address(newToken);
    }

    function buy(address _token) public payable {
        // calculate token amount
        uint256 tokenAmount = msg.value;
        // mint tokens
        Token(payable(_token)).mint(msg.sender, tokenAmount);
    }

    function sell(address _token, uint256 _amount) public payable {
        // burn tokens
        Token(_token).burn(msg.sender, _amount);
        // calculate ether amount
        uint etherAmount= _amount;
        // return ether
        (bool success, ) = address(msg.sender).call{value: etherAmount}("");
        require(success, "Transfer failed");
    }
}
