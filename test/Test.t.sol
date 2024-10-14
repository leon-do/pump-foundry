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
        // y = 1x
        Curve curve = new Curve(1, 1, 1);
        assertEq(curve.sqrt(4), 2);
        assertEq(curve.sqrt(9), 3);
        assertEq(curve.sqrt(24), 4); // round down
    }

    function test_Curve_sellFor() public {
        // y = 2x
        // auc = x^2
        Curve curve = new Curve(2, 1, 1);
        assertEq(curve.sellFor(5, 5), 25); // auc = 25, when selling all 5
        assertEq(curve.sellFor(4, 4), 16); // auc = 16, when selling all 4
        assertEq(curve.sellFor(5, (5 - 4)), (25 - 16)); // diff
    }

    function test_Curve_sellFor_ETH() public {
        // y = 2x
        // auc = x^2
        Curve curve = new Curve(2, 1, 10 ** 15);
        assertEq(
            curve.sellFor(0.005 * 10 ** 18, 0.005 * 10 ** 18),
            0.025 ether
        );
        assertEq(
            curve.sellFor(0.004 * 10 ** 18, 0.004 * 10 ** 18),
            0.016 ether
        );
        assertEq(
            curve.sellFor(0.005 * 10 ** 18, (0.001 * 10 ** 18)),
            (0.009 ether)
        ); // diff
    }

    function test_Curve_buyFor() public {
        // y = 2x
        // auc = x^2 -> x = sqrt(auc)
        Curve curve = new Curve(2, 1, 1);
        assertEq(curve.buyFor(0, 16), 4); // auc = 16, when supply 0 to 4
        assertEq(curve.buyFor(0, 25), 5); // auc = 25, when supply 0 to 5
        assertEq(curve.buyFor(4, 16), 1); // auc = 16, when supply 4 to 5
    }

    function test_Curve_buyFor_ETH() public {
        // y = 1/10**10 x
        Curve curve = new Curve(1, 10 ** 10, 10 ** 15);
        assertEq(curve.buyFor(0, 0.002 ether), 200 * 10 ** 18);
        assertEq(curve.buyFor(0, 0.008 ether), 400 * 10 ** 18);
        assertEq(curve.buyFor(0, 0.018 ether), 600 * 10 ** 18);
    }

    function test_Factory_Buy() public {
        Factory factory = new Factory();
        address token = factory.create("Token", "TKN");
        for (uint256 i = 0; i < 20; i++) {
            // alice buys tokens
            uint tokenAmount = factory.buy{value: 0.002 ether}(token);
            // alice should have tokens
            console.log(
                i,
                tokenAmount,
                Token(token).balanceOf(address(1)),
                address(factory).balance
            );
        }
    }
}
