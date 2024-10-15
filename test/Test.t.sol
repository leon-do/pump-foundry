// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Test, console} from "forge-std/Test.sol";
import {Factory} from "../src/Factory.sol";
import {Token} from "../src/Token.sol";
import {Curve} from "../src/Curve.sol";
import {Fee} from "../src/Fee.sol";

contract Contract is Test {
    Factory factory;

    function setUp() public {
        // EOA owner deploys factory
        vm.startPrank(address(1337));
        factory = new Factory();
        vm.stopPrank();
        // EOA alice interacts with factory
        startHoax(address(1), 100 ether);
    }

    function test_Token() public {
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

    function test_Factory_Buy() public {
        Curve curve = new Curve(1, 10 ** 30);
        address token = factory.create("Token", "TKN");
        uint256 curveAmount = curve.buyFor(Token(token).totalSupply(), 0.001 ether);
        uint256 tokenAmount = factory.buy{value: 0.001 ether}(token);
        // factory buy is the same as curve buy
        assertEq(tokenAmount, curveAmount);
    }

    function test_Factory_buyAndSell() public {
        Fee fee = new Fee(address(1));
        address token = factory.create("Token", "TKN");
        // alice buys 0.001 ether
        uint256 tokenAmount = factory.buy{value: 0.001 ether}(token);
        // total amount of ether to send
        uint256 ethAmount = factory.sell(token, tokenAmount);
        // 2% of total amount as fee
        uint256 feeAmount = fee.getAmount(ethAmount);
        // alice gets 98%
        uint256 userAmount = ethAmount - feeAmount;
        // feeAmount = ethAmount * 2%
        assertEq(feeAmount * 100, ethAmount * fee.percent());
        // alice gets 98%
        assertEq(userAmount, (ethAmount * (100 - fee.percent())) / 100);
        // owner fee balance
        assertEq(address(1337).balance, 0.00002 ether - 1);
    }
}
