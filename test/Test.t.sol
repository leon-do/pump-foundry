// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Test, console} from "forge-std/Test.sol";
import {Factory} from "../src/Factory.sol";
import {Token} from "../src/Token.sol";
import {Curve} from "../src/Curve.sol";

contract Contract is Test {
    Factory public factory = new Factory();
    Curve public curve = new Curve();
    address public token;
    address alice = address(1);

    function setUp() public {
        token = factory.create("Token", "TKN");
        startHoax(alice, 5 ether);
    }

    function test_Token() public view {
        string memory name = Token(token).name();
        assertEq(name, "Token");
        string memory symbol = Token(token).symbol();
        assertEq(symbol, "TKN");
    }

    function test_Curve_BuyFor() public view {
        uint256 supply = 1000;
        uint256 reserveBalance = 1000;
        uint32 reserveRatio = 500000;
        uint256 buyAmount = 1000;

        uint256 tokenAmount = curve.buyFor(supply, reserveBalance, reserveRatio, buyAmount);

        // tokenAmount = _supply * ((1 + buyAmount / _reserveBalance) ^ (_reserveRatio / MAX_RESERVE_RATIO) - 1)
        // 1000 * ((1 + 1000 / 1000) ** (500000 / 1000000) - 1)
        assertEq(tokenAmount, 414);
    }

    function test_Curve_SellFor() public view {
        uint256 supply = 1000;
        uint256 reserveBalance = 1000;
        uint32 reserveRatio = 500000;
        uint256 sellAmount = 100;

        uint256 tokenAmount = curve.sellFor(supply, reserveBalance, reserveRatio, sellAmount);

        // ETHAmount = _reserveBalance * (1 - (1 - _sellAmount / _supply) ** (1 / (_reserveRatio / MAX_RESERVE_RATIO)))
        // 1000 * (1 - (1 - 100 / 1000) ** (1 / (500000 / 1000000)))
        assertEq(tokenAmount, 189);
    }

    function test_Buy() public payable {
        // before alice buys tokens
        uint256 etherBalance = address(alice).balance;
        assertEq(etherBalance, 5 ether);
        uint256 tokenBalance = Token(token).balanceOf(alice);
        assertEq(tokenBalance, 0);
        uint256 factoryBalance = address(factory).balance;
        assertEq(factoryBalance, 0);
        // alice buy tokens
        factory.buy{value: 1 ether}(token);
        // after alice buys tokens
        etherBalance = address(alice).balance;
        assertEq(etherBalance, 4 ether);
        tokenBalance = Token(token).balanceOf(alice);
        assertEq(tokenBalance, 995443601);
        factoryBalance = address(factory).balance;
        assertEq(factoryBalance, 1 ether);
    }

    function test_Sell() public payable {
        // alice buy tokens
        factory.buy{value: 3 ether}(token);
        // alice sell tokens
        factory.sell(token, 1);
        // after selling tokens
        uint256 etherBalance = address(alice).balance;
        assertEq(etherBalance, 2 ether);
        uint256 factoryBalance = address(factory).balance;
        assertEq(factoryBalance, 3 ether);
        uint256 tokenBalance = Token(token).balanceOf(address(alice));
        assertEq(tokenBalance, 1720581240);
    }
}
