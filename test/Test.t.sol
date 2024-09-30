// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import {Test, console} from "forge-std/Test.sol";
import {Factory} from "../src/Factory.sol";
import {Token} from "../src/Token.sol";

contract Contract is Test {
    Factory public factory;
    address public token;
    address alice = address(1);

    function setUp() public {
        factory = new Factory();
        token = factory.create("Token", "TKN");
        startHoax(alice, 5);
    }

    function test_Token() public view {
        string memory name = Token(token).name();
        assertEq(name, "Token");
        string memory symbol = Token(token).symbol();
        assertEq(symbol, "TKN");
    }

    function test_Buy() public payable {
        // before alice buys tokens
        uint256 etherBalance = address(alice).balance;
        assertEq(etherBalance, 5);
        uint256 tokenBalance = Token(token).balanceOf(alice);
        assertEq(tokenBalance, 0);
        uint256 factoryBalance = address(factory).balance;
        assertEq(factoryBalance, 0);
        // alice buy tokens
        factory.buy{value: 1}(token);
        // after alice buys tokens
        etherBalance = address(alice).balance;
        assertEq(etherBalance, 4);
        tokenBalance = Token(token).balanceOf(alice);
        assertEq(tokenBalance, 1);
        factoryBalance = address(factory).balance;
        assertEq(factoryBalance, 1);
    }

    function test_Sell() public payable {
        // alice buy tokens
        factory.buy{value: 3}(token);
        // alice sell tokens
        factory.sell(token, 1);
        // after selling tokens
        uint256 etherBalance = address(alice).balance;
        assertEq(etherBalance, 3);
        uint256 factoryBalance = address(factory).balance;
        assertEq(factoryBalance, 2);
        uint256 tokenBalance = Token(token).balanceOf(address(alice));
        assertEq(tokenBalance, 2);
    }
}
