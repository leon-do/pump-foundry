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

    /**
     * https://github.com/user-attachments/assets/ec6bd1a4-8716-4783-bfdc-327970d224a1
     */
    function test_Curve_BuyFor() public view {
        uint256 totalSupply = 10;
        uint256 reserveBalance = 50;
        uint32 reserveRatio = 500_000; // 50%
        uint256 buyAmount = 151; // round up because of precision
        uint256 tokenAmount = curve.buyFor(
            totalSupply,
            reserveBalance,
            reserveRatio,
            buyAmount
        );
        // _totalSupply * ((1 + _buyAmount / _reserveBalance) ** (_reserveRatio / MAX_RESERVE_RATIO) - 1)
        // 10 * ((1 + 151 / 50) ** (0.5) - 1)
        assertEq(tokenAmount, 10);
    }

    function test_Curve_SellFor() public view {
        uint256 totalSupply = 20;
        uint256 reserveBalance = 200;
        uint32 reserveRatio = 500_000;
        uint256 sellAmount = 10;
        uint256 tokenAmount = curve.sellFor(
            totalSupply,
            reserveBalance,
            reserveRatio,
            sellAmount
        );
        // _reserveBalance * (1 - (1 - _sellAmount / _supply) ** (1 / (_reserveRatio / MAX_RESERVE_RATIO)))
        // 200 * (1 - (1 - 10 / 20) ** (1 / 0.5))
        assertEq(tokenAmount, 149);
    }

    function test_Factory_Buy_for() public {
        Factory factory = new Factory();
        uint32 reserveRatio = 500_000;
        address token = factory.create("Token", "TKN", reserveRatio);
        for (uint256 i = 0; i < 10; i++) {
            uint256 buyAmount = factory.buy{value: 0.1 * 1 ether}(token);
            uint256 totalSupply = Token(token).totalSupply();
            uint256 reserveBalance = factory.reserveBalances(token);
            console.log(buyAmount);
        }
    }
}
