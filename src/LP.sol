// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract LP {
    uint256 public liquidity = 1e11;
    uint256 public multiplier = 1e6;
    uint256 public margin = 50000;
    uint256[3] public ratiosWin;
    uint256 public totalPayOut;

    constructor(uint256[3] memory _ratio) {
        ratiosWin = _ratio;
    }

    function placeBet(uint256 _amount, uint8 _outcome) public {
        if (_outcome != 0 && _outcome != 1 && _outcome != 2)
            revert IncorectOutcome();
        uint256[3] memory _odds = calculateOdd(_amount, _outcome);
        if (_odds[_outcome] <= multiplier) revert OverMaxAmountBet();
        if (
            totalPayOut + (_amount * _odds[_outcome]) / multiplier >=
            liquidity + _amount
        ) revert NotEnoughLiquidity();
        for (uint8 i = 0; i < 3; i++) {
            if (i == _outcome) {
                ratiosWin[i] =
                    (((((ratiosWin[i] / 100) * liquidity) /
                        multiplier +
                        _amount) * multiplier) / (liquidity + _amount)) *
                    100;
            } else {
                ratiosWin[i] =
                    (((((ratiosWin[i] / 100) * liquidity) / multiplier) *
                        multiplier) / (liquidity + _amount)) *
                    100;
            }
        }
        liquidity += _amount;
        totalPayOut += (_amount * _odds[_outcome]) / multiplier;
        emit PlaceBet(
            _amount,
            _odds[_outcome],
            _outcome,
            liquidity,
            totalPayOut
        );
    }

    function calculateOdd(uint256 _amount, uint8 _outcome)
        public
        view
        returns (uint256[3] memory)
    {
        uint256[3] memory _odds;
        for (uint8 i = 0; i < 3; i++) {
            if (i == _outcome) {
                _odds[i] =
                    ((liquidity + _amount) * multiplier) /
                    ((liquidity * ratiosWin[i]) / multiplier / 100 + _amount);
            } else {
                _odds[i] =
                    ((liquidity + _amount) * multiplier) /
                    ((liquidity * ratiosWin[i]) / multiplier / 100);
            }
        }

        return (
            [
                (_odds[0] * multiplier) / (multiplier + margin),
                (_odds[1] * multiplier) / (multiplier + margin),
                (_odds[2] * multiplier) / (multiplier + margin)
            ]
        );
    }

    event PlaceBet(
        uint256 amount,
        uint256 odd,
        uint8 outcome,
        uint256 liquidity,
        uint256 payOut
    );

    error IncorectOutcome();
    error NotEnoughLiquidity();
    error OverMaxAmountBet();
}
