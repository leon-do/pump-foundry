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

    function test_Curve_BuyFor() public view {
        uint256 totalSupply = 100_000_000 ether;
        uint256 reserveBalance = 0.5 ether;
        uint256 buyAmount = 1 ether;
        uint256 tokenAmount = curve.buyFor(
            totalSupply,
            reserveBalance,
            buyAmount
        );
        assertEq(tokenAmount, 666166676666666691666); // 666 ether
    }

    function test_Curve_SellFor() public view {
        uint256 totalSupply = 100_000_000 ether;
        uint256 reserveBalance = 999 ether;
        uint256 sellAmount = 0.001 ether;
        uint256 tokenAmount = curve.sellFor(
            totalSupply,
            reserveBalance,
            sellAmount
        );
        assertEq(tokenAmount, 332333336673333341634); // 332 ether
    }

    // function test_Factory_Buy() public payable {
    //     Factory factory = new Factory();
    //     address token = factory.create("Token", "TKN");
    //     for (uint256 i = 1; i < 21; i++) {
    //         factory.buy{value: 0.001 ether}(token);
    //         uint totalSupply = Token(token).totalSupply();
    //         uint price = factory.buyFor(token, i);
    //         console.log(totalSupply, price);
    //     }
    // }
}
