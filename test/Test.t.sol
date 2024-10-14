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
        address token = factory.create("Token", "TKN");
        string memory name = Token(token).name();
        assertEq(name, "Token");
        string memory symbol = Token(token).symbol();
        assertEq(symbol, "TKN");
    }

    function test_Curve_Sqrt() public {
        Curve curve = new Curve(1, 1);
        assertEq(curve.sqrt(4), 2);
        assertEq(curve.sqrt(9), 3);
        assertEq(curve.sqrt(24), 4); // round down
    }

    function test_Curve_sellFor() public {
        Curve curve = new Curve(1, 1);
        assertEq(curve.sellFor(5, 5), 12);
        assertEq(curve.sellFor(4, 4), 8);
        assertEq(curve.sellFor(5, 1), 4);
    }

    function test_Curve_buyFor() public {
        Curve curve = new Curve(1, 1);
        assertEq(curve.buyFor(0, 2), 2);
        assertEq(curve.buyFor(0, 18), 6);
        assertEq(curve.buyFor(0, 32), 8);
    }

    function test_Curve_sellFor_Ether() public {
        Curve curve = new Curve(1, 10 ** 28);
        uint256 totalSupply = 5000 * 10 ** 18;
        uint256 sellAmount = 5000 * 10 ** 18;
        uint256 ethAmount = 0.00125 ether;
        assertEq(curve.sellFor(totalSupply, sellAmount), ethAmount);
    }

    function test_Curve_buyFor_Ether() public {
        Curve curve = new Curve(1, 10 ** 28);
        uint256 totalSupply = 0;
        uint256 buyAmount = 0.00125 ether;
        uint256 tokenAmount = 5000 * 10 ** 18;
        assertEq(curve.buyFor(totalSupply, buyAmount), tokenAmount);
    }
}
