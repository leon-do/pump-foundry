// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Test, console} from "forge-std/Test.sol";
import {Factory} from "../src/Factory.sol";
import {Token} from "../src/Token.sol";
import {Curve} from "../src/Curve.sol";
import {Fee} from "../src/Fee.sol";

contract Contract is Test {
    Curve public curve = new Curve();

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

    /*
     * fee of 25 = 25%
     */
    function test_Fee() public {
        Fee fee = new Fee(address(1));
        fee.setFee(25);
        uint256[2] memory fees = fee.getAmount(100);
        assertEq(fees[0], 25);
        assertEq(fees[1], 75);
    }

    function test_Curve_Sqrt() public view {
        uint256 x = 16;
        uint256 y = curve.sqrt(x);
        assertEq(y, 4);

        x = 121 ether;
        y = curve.sqrt(x);
        assertEq(y, 11 * 10 ** 9);

        x = 15;
        y = curve.sqrt(x);
        assertEq(y, 3);
    }

    function test_Curve_sellFor() public view {
        uint256 totalSupply = 3 ether;
        uint256 sellAmount = 1 ether;
        uint256 ethAmount = curve.sellFor(totalSupply, sellAmount);
        // 3**2 - ((3 - 1)**2)
        assertEq(ethAmount, 5 ether);
    }

    function test_Curve_buyFor() public view {
        uint256 totalSupply = 2 ether;
        uint256 buyAmount = 5 ether;
        uint256 tokenAmount = curve.buyFor(totalSupply, buyAmount);
        // ((2**2 + 5)**0.5) - 2
        assertEq(tokenAmount, 1 ether);
    }
}
