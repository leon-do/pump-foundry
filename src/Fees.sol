// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Fees is Ownable {
    uint256 public percent = 2;

    constructor(address _owner) Ownable(_owner) {}

    function getAmount(uint256 _amount) public view returns (uint256 amount) {
        amount = (_amount * percent) / 100;
    }

    function setPercent(uint256 _percent) public onlyOwner {
        percent = _percent;
    }
}
