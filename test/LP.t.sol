// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import {LP} from "../src/LP.sol";

contract TestLP is Test {
    LP lp;

    address owner = 0x9B853D7cCE80FFeCf0aCB6408f11cdD3243bbBdB;
    address alice = 0xDe8fF72681B9AD66e116Bc3558E3e20da251d5dE;
    uint256[] _ratio0 = [uint256(60000000), uint256(40000000)];

    uint256[] _ratio1 = [uint256(0), uint256(0)];

    function setUp() public {
        vm.prank(owner);
        lp = new LP();
        lp.createEvent(_ratio0, _ratio1, 2);
        lp.createEvent(_ratio0, _ratio1, 2);
    }

    uint256[] amount = [
        10e6,
        10e6,
        10e6,
        10e6,
        10e6,
        10e6,
        10e6,
        10e6,
        10e6,
        10e6
    ];
    uint8[] outcome = [0, 0, 0, 0, 0, 1, 1, 1, 1, 1];
    //uint8[] outcome = [0,1,0,1,0,1,0,1,0,1];
    uint8[] eventId = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

    function testCase() public {
        for (uint8 i = 0; i < 10; i++) {
            console.log("---- amount", amount[i], "and out come ", outcome[i]);
            console.log("  Before :");
            lp.calculateOdd(0, outcome[i], eventId[i]);
            console.log("  Calcu :");
            lp.placeBet(amount[i], outcome[i], eventId[i]);
            console.log("  After :");
           // lp.calculateOdd(0, outcome[i], eventId[i]);
        }
        console.log("-----------------------");
        console.log("totalPnlLP", lp.pnlLp());
    }
}
