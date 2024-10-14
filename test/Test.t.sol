// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Test, console} from "forge-std/Test.sol";
import {Factory} from "../src/Factory.sol";
import {Token} from "../src/Token.sol";
import {Curve} from "../src/Curve.sol";
import {Fee} from "../src/Fee.sol";

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

    function test_Fees() public {
        Fee fee = new Fee(address(1));
        address owner = fee.owner();
        assertEq(owner, address(1));
        assertEq(fee.percent(), 2);
        // get fees
        uint256 feeAmount = fee.getAmount(100);
        assertEq(feeAmount, 2);
        // alice sets percent
        fee.setPercent(3);
        assertEq(fee.percent(), 3);
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
        Curve curve = new Curve(1, 10 ** 30);
        uint256 totalSupply = 50_000 * 10 ** 18;
        uint256 sellAmount = 50_000 * 10 ** 18;
        uint256 ethAmount = 0.00125 ether;
        assertEq(curve.sellFor(totalSupply, sellAmount), ethAmount);
    }

    function test_Curve_buyFor_Ether() public {
        Curve curve = new Curve(1, 10 ** 30);
        uint256 totalSupply = 0;
        uint256 buyAmount = 0.00125 ether;
        uint256 tokenAmount = 50_000 * 10 ** 18;
        assertEq(curve.buyFor(totalSupply, buyAmount), tokenAmount);
    }

    function test_Factory_buyLoop() public {
        Factory factory = new Factory();
        address token = factory.create("Token", "TKN");
        for (uint256 i = 1; i < 5_000; i = i + 100) {
            // alice buys 0.001 ether
            uint256 tokenAmount = factory.buy{value: 0.001 ether}(token);
            console.log(i, tokenAmount / 10 ** 18);
        }
    }

    function test_Factory_buyAndSell() public {
        Factory factory = new Factory();
        Fee fee = new Fee(address(1));
        address token = factory.create("Token", "TKN");
        for (uint256 i = 1; i < 5_000; i = i + 100) {
            // alice buys 0.001 ether
            uint256 tokenAmount = factory.buy{value: 0.001 ether}(token);
            uint256 ethAmount = factory.sell(token, tokenAmount);
            uint256 feeAmount = fee.getAmount(ethAmount);
            uint256 userAmount = ethAmount - feeAmount;
            // 2% fee
            assertEq((feeAmount * 100) / ethAmount, fee.percent());
            // user gets 98%
            assertEq(userAmount, (ethAmount * (100 - fee.percent())) / 100);
        }
        // balance of owner
        assertEq(fee.owner(), address(1));
        assertGt(address(1).balance, 1);
    }
}
