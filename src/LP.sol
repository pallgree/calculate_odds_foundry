// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "../lib/forge-std/src/Test.sol";

contract LP {
    uint256 public liquidity = 1e12;
    uint256 public multiplier = 1e6;
    uint256[3] public ratiosWin;
    uint256 public totalNetBet;
    uint256 public totalPayOut;

    constructor (uint256[3] memory _ratio) {
            ratiosWin = _ratio;
    }

    function placeBet(uint256 _amount, uint8 _outcome) public {
        if (_outcome != 0 && _outcome != 1 && _outcome != 2) revert IncorectOutcome();
        uint256 _odd = (liquidity + _amount) * multiplier / (liquidity * ratiosWin[_outcome] / multiplier + _amount);
        if (totalPayOut + _amount * _odd >= liquidity) revert NotEnoughLiquidity();
        for (uint8 i = 0; i < 3; i++) {
            if (i != _amount) {
                ratiosWin[i] = (ratiosWin[i] / 100 * liquidity) * multiplier / (liquidity + _amount);
            } else {
                ratiosWin[i] = (ratiosWin[i] / 100 * liquidity + _amount) * multiplier / (liquidity + _amount);
            }
        }
        liquidity += _amount;
        totalPayOut += _amount * _odd;
        emit PlaceBet(_amount,_odd,_outcome);
    }
    
     event PlaceBet(
        uint256 amount,
        uint256 odd,
        uint8 outcome
    );

    error IncorectOutcome();
    error NotEnoughLiquidity();
}