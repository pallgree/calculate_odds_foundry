// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import {LP} from "../src/LP.sol";

contract TestLP is Test {
    LP lp;

    address owner = 0x9B853D7cCE80FFeCf0aCB6408f11cdD3243bbBdB;
    address alice = 0xDe8fF72681B9AD66e116Bc3558E3e20da251d5dE;
    uint256[] _ratio0 = [
        uint256(45000000),
        uint256(10000000),
        uint256(30000000),
        uint256(10000000),
        uint256(5000000)
    ];

    uint256[] _ratio1 = [
        uint256(0),
        uint256(0),
        uint256(0),
        uint256(0),
        uint256(0)
    ];

    function setUp() public {
        vm.prank(owner);
        lp = new LP();
        lp.createEvent(_ratio0, _ratio1, 5);
        lp.createEvent(_ratio0, _ratio1, 5);
    }

    function testPlaceBet1() public {
        lp.placeBet(10000e6, 0, 0);
        lp.placeBet(10000e6, 1, 0);
        lp.placeBet(10000e6, 2, 0);
        lp.placeBet(10000e6, 3, 0);
        lp.placeBet(10000e6, 4, 0);
        lp.placeBet(80000e6, 0, 0);
    }
}
