// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {LP} from "../src/LP.sol";

contract TestLP is Test {
    LP lp;
    address owner = 0x9B853D7cCE80FFeCf0aCB6408f11cdD3243bbBdB;
    address alice = 0xDe8fF72681B9AD66e116Bc3558E3e20da251d5dE;
    

    function setUp() public {
         uint256[3] memory _odds = [uint256(45000000), uint256(25000000), uint256(30000000)];
         vm.prank(owner);
         lp = new LP(_odds);
    }

    // function testPlaceBet() public {
    //     vm.prank(owner);
    //     lp.placeBet(200000000, 0);
    // }                           
}
