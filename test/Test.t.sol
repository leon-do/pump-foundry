// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Test, console} from "forge-std/Test.sol";
import {Factory} from "../src/Factory.sol";
import {Token} from "../src/Token.sol";
import {Curve} from "../src/Curve.sol";

contract Contract is Test {
    Curve public curve = new Curve();

    function setUp() public {
        // start alice with ether
        startHoax(address(1), 5 ether);
    }

    function test_Token() public {
        Factory factory = new Factory();
        address token = factory.create("Token", "TKN", 500_000);
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
        uint256 tokenAmount = curve.buyFor(
            supply,
            reserveBalance,
            reserveRatio,
            buyAmount
        );
        // tokenAmount = _supply * ((1 + buyAmount / _reserveBalance) ^ (_reserveRatio / MAX_RESERVE_RATIO) - 1)
        // 1000 * ((1 + 1000 / 1000) ** (500000 / 1000000) - 1)
        assertEq(tokenAmount, 414);
    }

    function test_Curve_SellFor() public view {
        uint256 supply = 1000;
        uint256 reserveBalance = 1000;
        uint32 reserveRatio = 500000;
        uint256 sellAmount = 100;
        uint256 tokenAmount = curve.sellFor(
            supply,
            reserveBalance,
            reserveRatio,
            sellAmount
        );
        // ETHAmount = _reserveBalance * (1 - (1 - _sellAmount / _supply) ** (1 / (_reserveRatio / MAX_RESERVE_RATIO)))
        // 1000 * (1 - (1 - 100 / 1000) ** (1 / (500000 / 1000000)))
        assertEq(tokenAmount, 189);
    }

    /*
     * ratio 1_000_000 ppm == 100%
     * if ratio = 100% then y = 1
     * integral of y = 1 is ∫y = x
     * below tests ∫y = x
     **/
    function test_Ratio100() public payable {
        Factory factory = new Factory();
        address token = factory.create("Token", "TKN", 1_000_000);
        for (uint256 i = 1; i < 21; i++) {
            factory.buy{value: 1}(token);
            uint totalSupply = Token(token).totalSupply();
            uint price = factory.buyFor(token, i);
            assertEq(totalSupply, price);
        }
    }
}
