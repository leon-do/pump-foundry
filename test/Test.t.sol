// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Test, console} from "forge-std/Test.sol";
import {Factory} from "../src/Factory.sol";
import {Token} from "../src/Token.sol";
import {Curve} from "../src/Curve.sol";

contract Contract is Test {
    function setUp() public {
        // start alice with ether
        startHoax(address(1), 100 ether);
    }

    function test_Token() public {
        Factory factory = new Factory();
        uint32 reserveRatio = 500_000;
        address token = factory.create("Token", "TKN", reserveRatio);
        string memory name = Token(token).name();
        assertEq(name, "Token");
        string memory symbol = Token(token).symbol();
        assertEq(symbol, "TKN");
    }

    // https://github.com/user-attachments/assets/fc25ca23-4114-4da3-a525-e3d40881f4ab
    function test_Curve_SellFor_A() public {
        Curve curve = new Curve(1, 0);
        uint256 totalSupply = 4;
        uint256 sellAmount = 2;
        uint256 ethAmount = curve.sellFor(totalSupply, sellAmount);
        assertEq(ethAmount, 6);
    }

    function test_Curve_SellFor_B() public {
        Curve curve = new Curve(1, 0);
        uint256 totalSupply = 20;
        uint256 sellAmount = 10;
        uint256 ethAmount = curve.sellFor(totalSupply, sellAmount);
        assertEq(ethAmount, 150);
    }

    // https://github.com/user-attachments/assets/3827d11f-9550-4d40-9911-171798690c3c
    function test_Curve_BuyFor_A() public {
        Curve curve = new Curve(1, 0);
        uint256 totalSupply = 2;
        uint256 buyAmount = 6;
        uint256 tokenAmount = curve.buyFor(totalSupply, buyAmount);
        assertEq(tokenAmount, 2);
    }

    function test_Curve_BuyFor_B() public {
        Curve curve = new Curve(1, 0);
        uint256 totalSupply = 2;
        uint256 buyAmount = 16;
        uint256 tokenAmount = curve.buyFor(totalSupply, buyAmount);
        assertEq(tokenAmount, 4);
    }
}
