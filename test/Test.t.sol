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
        uint256 totalSupply = 1;
        uint256 reserveBalance = 1;
        uint32 reserveRatio = 500_000; // 50%
        uint256 buyAmount = 50; // round up because of precision
        uint256 tokenAmount = curve.buyFor(
            totalSupply,
            reserveBalance,
            reserveRatio,
            buyAmount
        );
        // _totalSupply * ((1 + _buyAmount / _reserveBalance) ** (_reserveRatio / MAX_RESERVE_RATIO) - 1)
        // 10 * ((1 + 151 / 50) ** (0.5) - 1)
        assertEq(tokenAmount, 6);
    }

    function test_Curve_SellFor() public view {
        uint256 totalSupply = 7;
        uint256 reserveBalance = 50;
        uint32 reserveRatio = 500_000;
        uint256 sellAmount = 1;
        uint256 tokenAmount = curve.sellFor(
            totalSupply,
            reserveBalance,
            reserveRatio,
            sellAmount
        );
        // _reserveBalance * (1 - (1 - _sellAmount / _supply) ** (1 / (_reserveRatio / MAX_RESERVE_RATIO)))
        // 50 * (1 - (1 - 1 / 7) ** (1 / 0.5))
        assertEq(tokenAmount, 13); // 13.265306122448973
    }

    function test_Factory_Buy_Sell() public {
        Factory factory = new Factory();
        uint32 reserveRatio = 500_000;
        address token = factory.create("Token", "TKN", reserveRatio);

        // matches test_Curve_BuyFor
        uint256 initialTotalSupply = Token(token).totalSupply();
        assertEq(initialTotalSupply, 10 ** 18);
        uint256 initialReserveBalance = factory.reserveBalances(token);
        assertEq(initialReserveBalance, 0);
        uint256 buyAmount = factory.buy{value: 50 ether}(token);
        assertEq(buyAmount, 6 * 10 ** 18);

        // matches test_Curve_SellFor
        assertEq(Token(token).totalSupply(), 7 * 10 ** 18);
        uint256 sellAmount = factory.sell(token, 1 * 10 ** 18);
        assertEq(sellAmount, 13265306122448979591); // 13 ether
    }
}
