// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/console.sol";

library Newton {
    function adjustOddsWithMargin(
        uint256[] memory pOdds,
        uint256 margin,
        uint256 multiplier
    ) public pure returns (uint256[] memory) {
        uint numberOfOdds = pOdds.length;
        uint256[] memory cOdds = new uint256[](numberOfOdds);
        uint256 k = solve(0, pOdds, margin, 10, 10, 20, multiplier);
        require(k != 0, "adjustOddsWithMargin: no odds");
        for (uint i = 0; i < numberOfOdds; i++) {
            cOdds[i] = (multiplier +
                (k * (pOdds[i] - multiplier)) /
                multiplier);
        }
        return cOdds;
    }

    /**
     * use Newton method to solve equation.
     * choose tolerance = 10, epsilon=10, maxIter = 20
     */
    function solve(
        uint256 x0,
        uint256[] memory p,
        uint256 margin,
        uint256 epsilon,
        uint256 tolerance,
        uint256 maxIter,
        uint256 multiplier
    ) public pure returns (uint256) {
        uint iter;
        uint256 x1;
        bool unableSolve;
        while (++iter < maxIter) {
            uint256 y = f(x0, p, margin, multiplier);
            uint256 yp = fp(x0, p, multiplier);
            // Check for badly conditioned update (extremely small first deriv relative to function):
            if (multiplier * yp <= epsilon * y) {
                unableSolve = true; // failed
                break;
            }
            // Update the guess:
            x1 = x0 + ((multiplier * y) / yp); // x1= x0 - y/yp, but yp < 0, so change from - to +
            // Check for convergence:
            if (multiplier * subtract(x1, x0) <= tolerance * x1) break; // success
            x0 = x1;
        }
        if (unableSolve) return 0;
        else return x1;
    }

    /**
     * return abs(f)
     */
    function f(
        uint256 x,
        uint256[] memory p,
        uint256 margin,
        uint256 multiplier
    ) public pure returns (uint256) {
        uint256 sum;
        for (uint i = 0; i < p.length; i++) {
            sum +=
                (multiplier ** 3) /
                (x * (p[i] - multiplier) + multiplier ** 2);
        }
        if (sum > multiplier + margin) return sum - (multiplier + margin);
        else return (multiplier + margin) - sum;
    }

    /**
     * return abs(fp)
     * actually with this function fp always < 0
     */
    function fp(
        uint256 x,
        uint256[] memory p,
        uint256 multiplier
    ) public pure returns (uint256) {
        uint256 sum;
        for (uint i = 0; i < p.length; i++) {
            sum +=
                ((p[i] - multiplier) * multiplier ** 4) /
                (((p[i] - multiplier) * x + multiplier ** 2) *
                    ((p[i] - multiplier) * x + multiplier ** 2));
        }
        return sum;
    }

    /**
     * return abs(x-y)
     */
    function subtract(uint256 x, uint256 y) public pure returns (uint256) {
        if (x > y) return x - y;
        else return y - x;
    }
}
