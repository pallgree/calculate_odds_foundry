// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {LP} from "../src/LP.sol";

contract TestLP is Test {
    LP lp;
    address owner = 0x9B853D7cCE80FFeCf0aCB6408f11cdD3243bbBdB;
    address alice = 0xDe8fF72681B9AD66e116Bc3558E3e20da251d5dE;
    

    function setUp() public {
         uint256[3] memory _ratio = [uint256(45000000), uint256(25000000), uint256(30000000)];
         vm.prank(owner);
         lp = new LP(_ratio);
         console.log("-------- reinforcement: 1e11 -----------");
         console.log("");
    }

    function testPlaceBet1() public {
        vm.startPrank(owner);
        console.log("1.--place bet amount 2e8 with outcome 0--");
        uint256[3] memory odds = lp.calculateOdd(0,0);
        console.log("odds before:",odds[0],odds[1],odds[2]);
        console.log("1+m:",1e12/odds[0]+1e12/odds[1]+1e12/odds[2]);
        odds = lp.calculateOdd(2e8,0);
        console.log("odds after:",odds[0],odds[1],odds[2]);
         console.log("1+m:",1e12/odds[0]+1e12/odds[1]+1e12/odds[2]);
        lp.placeBet(2e8, 0);
        console.log("");
         console.log("2.--place bet amount 1e12 with outcome 0--");
        odds = lp.calculateOdd(0,0);
        console.log("odds before:",odds[0],odds[1],odds[2]);
        console.log("1+m:",1e12/odds[0]+1e12/odds[1]+1e12/odds[2]);
        odds = lp.calculateOdd(1e12,0);
        console.log("odds after:",odds[0],odds[1],odds[2]);
         console.log("1+m:",1e12/odds[0]+1e12/odds[1]+1e12/odds[2]);
        lp.placeBet(1e12, 0);
        console.log("");
         console.log("3.--place bet amount 1e8 with outcome 1--");
        odds = lp.calculateOdd(0,0);
        console.log("odds before:",odds[0],odds[1],odds[2]);
        console.log("1+m:",1e12/odds[0]+1e12/odds[1]+1e12/odds[2]);
        odds = lp.calculateOdd(1e8,1);
        console.log("odds after:",odds[0],odds[1],odds[2]);
         console.log("1+m:",1e12/odds[0]+1e12/odds[1]+1e12/odds[2]);
        lp.placeBet(1e8, 1);

        console.log("");
         console.log("4.--place bet amount 3e9 with outcome 2--");
        odds = lp.calculateOdd(0,0);
        console.log("odds before:",odds[0],odds[1],odds[2]);
        console.log("1+m:",1e12/odds[0]+1e12/odds[1]+1e12/odds[2]);
        odds = lp.calculateOdd(3e9,2);
        console.log("odds after:",odds[0],odds[1],odds[2]);
         console.log("1+m:",1e12/odds[0]+1e12/odds[1]+1e12/odds[2]);
        lp.placeBet(3e9, 2);


        console.log(""); console.log("");
        console.log("liquidity + netBet - payOut = ",lp.liquidity() - lp.totalPayOut());
        console.log("totalNetBet =", lp.liquidity() - uint256(1e11));



    }     
                          
}
