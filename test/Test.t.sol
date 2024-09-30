// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Factory} from "../src/Factory.sol";
import {Token} from "../src/Token.sol";

contract Contract is Test {
    Factory public factory;
    address public token;

    function setUp() public {
        factory = new Factory();
        token = factory.create("Token", "TKN");
    }

    function test_Balance() public view {
        assertEq(address(this).balance, 79228162514264337593543950335);
    }

    function test_Token() public view {
        string memory name = Token(token).name();
        assertEq(name, "Token");
        string memory symbol = Token(token).symbol();
        assertEq(symbol, "TKN");
    }

    function test_Buy() public payable {
        // before buying tokens
        uint256 etherBalance = address(this).balance;
        assertEq(etherBalance, 79228162514264337593543950335);
        uint256 tokenBalance = Token(token).balanceOf(address(this));
        assertEq(tokenBalance, 0);
        uint256 factoryBalance = address(factory).balance;
        assertEq(factoryBalance, 0);
        // buy tokens
        factory.buy{value: 1}(token);
        // after buying tokens
        etherBalance = address(this).balance;
        assertEq(etherBalance, 79228162514264337593543950335 - 1);
        tokenBalance = Token(token).balanceOf(address(this));
        assertEq(tokenBalance, 1);
        factoryBalance = address(factory).balance;
        assertEq(factoryBalance, 1);
    }

    function test_Sell() public {
        // before selling tokens
        uint256 etherBalance = address(this).balance;
        assertEq(etherBalance, 79228162514264337593543950335);
        uint256 tokenBalance = Token(token).balanceOf(address(this));
        assertEq(tokenBalance, 0);
        uint256 factoryBalance = address(factory).balance;
        assertEq(factoryBalance, 0);

        // buy tokens
        factory.buy{value: 5}(token);

        // after buying tokens
        etherBalance = address(this).balance;
        assertEq(etherBalance, 79228162514264337593543950335 - 5);
        tokenBalance = Token(token).balanceOf(address(this));
        assertEq(tokenBalance, 5);
        factoryBalance = address(factory).balance;
        assertEq(factoryBalance, 5);

        // sell tokens
        factory.sell(token, 2);

        // after selling tokens
        // etherBalance = address(this).balance;
        // assertEq(etherBalance, 79228162514264337593543950335 - 2);
        tokenBalance = Token(token).balanceOf(address(this));
        assertEq(tokenBalance, 3);
        // factoryBalance = address(factory).balance;
        // assertEq(factoryBalance, 3 ether);
    }
}
