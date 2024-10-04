// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "./Factory.sol";

/**
 * @title Token contract is created by the factory contract.
 * It is a standard ERC20 token
 * Minting and burning are restricted to the owner (factory contract)
 **/
contract Token is ERC20, ERC20Burnable, Ownable, ERC20Permit {
    /**
     * @param _name of token
     * @param _symbol of token
     * @param _owner of token (factory address)
     */
    constructor(
        string memory _name,
        string memory _symbol,
        address _owner
    ) ERC20Permit(_name) ERC20(_name, _symbol) Ownable(_owner) {}

    // only factory can mint
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    // only factory can burn
    function burn(address from, uint256 amount) public onlyOwner {
        _burn(from, amount);
    }
}
