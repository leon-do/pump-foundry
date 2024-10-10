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
        Curve curve = new Curve(1, 0); // y = 1x + 0
        assertEq(curve.sqrt(4), 2);
        assertEq(curve.sqrt(9), 3);
        assertEq(curve.sqrt(24), 4); // round down
    }

    function test_Curve_Abs() public {
        Curve curve = new Curve(1, 0); // y = 1x + 0
        assertEq(curve.abs(-4), 4);
        assertEq(curve.abs(-9), 9);
        assertEq(curve.abs(16), 16);
    }

    function test_Curve_AUC() public {
        Curve curve = new Curve(2, -2); // y = 2x - 2
        // auc = x^2 - 2x
        assertEq(curve.auc(2), 0); // 2^2 - 2*2 = 0
        assertEq(curve.auc(3), 3); // 3^2 - 2*3 = 3
        assertEq(curve.auc(4), 8); // 4^2 - 2*4 = 8
    }

    function test_Curve_sellFor() public {
        Curve curve = new Curve(2, -2); // y = 2x - 2
        // auc = x^2 - 2x
        assertEq(curve.sellFor(5, 5), 15); // auc of 5 is 15
        assertEq(curve.sellFor(4, 4), 8); // auc of 4 is 8
        assertEq(curve.sellFor(5, (5 - 4)), (15 - 8)); // diff is 7
    }

    function test_Curve_buyFor() public {
        Curve curve = new Curve(2, -2); // y = 2x - 2
        // auc = x^2 - 2x
        assertEq(curve.buyFor(2, 3), 1); // auc = 3, when supply 2 to 3 (2+1)
        assertEq(curve.buyFor(2, 8), 2); // auc = 8, when supply 2 to 4 (2+2)
        assertEq(curve.buyFor(2, 15), 3); // auc = 15 when supply 2 to 5 (2+3)
    }
}
