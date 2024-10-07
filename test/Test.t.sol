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
        uint32 reserveRatio = 500_000;
        address token = factory.create("Token", "TKN", reserveRatio);
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

    // https://github.com/user-attachments/assets/fc25ca23-4114-4da3-a525-e3d40881f4ab
    function test_Curve_SellFor() public view {
        uint256 totalSupply = 4;
        uint256 sellAmount = 2;
        uint256 ethAmount = curve.sellFor(totalSupply, sellAmount);
        assertEq(ethAmount, 6);
    }

    // https://github.com/user-attachments/assets/3827d11f-9550-4d40-9911-171798690c3c
    function test_Curve_BuyFor() public view {
        uint256 totalSupply = 2;
        uint256 buyAmount = 6;
        uint256 tokenAmount = curve.buyFor(totalSupply, buyAmount);
        assertEq(tokenAmount, 2);
    }
}
