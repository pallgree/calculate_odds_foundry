// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;
import "forge-std/Test.sol";
import {Newton} from "./Newton.sol";

contract LP {
    uint256 public liquidity = 1e10;
    uint256 public reserve = 1e10;
    uint256 public reinforcementDefault = 1e9;
    uint256 public multiplier = 1e6;
    uint256 public margin = 50000;
    uint8 public lastEventId;
    uint256 public totalPayoff;

    mapping(uint256 => EventInfo) public eventInfos;

    struct EventInfo {
        uint8 eventId;
        uint8 market;
        uint256 reinforcement;
        uint256[] ratioWin;
        uint256 maxPayOut;
        uint256[] payOut;
        uint256[] NetBet;
        uint256 totalNetBet;
    }

    function createEvent(
        uint256[] memory _ratioWin,
        uint256[] memory _init,
        uint8 _market
    ) public {
        EventInfo storage eventInfo = eventInfos[lastEventId];
        eventInfo.eventId = lastEventId;
        eventInfo.market = _market;
        eventInfo.reinforcement = reinforcementDefault;
        eventInfo.ratioWin = _ratioWin;
        eventInfo.payOut = _init;
        eventInfo.NetBet = _init;
        lastEventId++;
    }

    function placeBet(uint256 _amount, uint8 _outcome, uint8 _eventId) public {
        EventInfo storage eventInfo = eventInfos[_eventId];
        if (eventInfo.reinforcement == 0) revert EventNotExits();
        if (_outcome < 0 || _outcome > eventInfo.market)
            revert IncorectOutcome();
        uint256 _odd = calculateOdd(_amount, _outcome, _eventId);
        if (_odd < multiplier) revert OverMaxAmountBet();
        uint256 spendingMaxpayOut = max(
            eventInfo.payOut,
            eventInfo.payOut[_outcome] + (_amount * _odd) / multiplier
        );
        uint256 detal;
        if (spendingMaxpayOut > eventInfo.maxPayOut + _amount) {
            detal = spendingMaxpayOut - eventInfo.maxPayOut - _amount;
        } else {
            detal = 0;
        }
        if (reserve < totalPayoff + detal) revert NotEnoughLiquidity();
        for (uint8 i = 0; i < eventInfo.market; i++) {
            if (i == _outcome) {
                eventInfo.ratioWin[i] =
                    (((((eventInfo.ratioWin[i] / 100) *
                        eventInfo.reinforcement) /
                        multiplier +
                        _amount) * multiplier) /
                        (eventInfo.reinforcement + _amount)) *
                    100;
            } else {
                eventInfo.ratioWin[i] =
                    (((((eventInfo.ratioWin[i] / 100) *
                        eventInfo.reinforcement) / multiplier) * multiplier) /
                        (eventInfo.reinforcement + _amount)) *
                    100;
            }
        }

        //update state
        eventInfo.reinforcement += _amount;
        eventInfo.payOut[_outcome] += (_amount * _odd) / multiplier;
        eventInfo.maxPayOut = max(eventInfo.payOut, 0);
        eventInfo.NetBet[_outcome] += _amount;
        eventInfo.totalNetBet += _amount;
        totalPayoff += detal;

        emit PlaceBet(
            _amount,
            _odd,
            _outcome,
            eventInfo.reinforcement,
            eventInfo.maxPayOut
        );
    }

    function calculateOddNewton(
        uint256 _amount,
        uint8 _outcome,
        uint8 _eventId,
        uint256 _market
    ) public view returns (uint256) {
        EventInfo storage eventInfo = eventInfos[_eventId];
        uint256[] memory pOdds = new uint256[](_market);
        for (uint8 i = 0; i < _market; i++) {
            if (i == _outcome) {
                pOdds[i] =
                    ((eventInfo.reinforcement + _amount) * multiplier) /
                    ((eventInfo.reinforcement * eventInfo.ratioWin[i]) /
                        multiplier /
                        100 +
                        _amount);
            } else {
                pOdds[i] =
                    ((eventInfo.reinforcement + _amount) * multiplier) /
                    ((eventInfo.reinforcement * eventInfo.ratioWin[i]) /
                        multiplier /
                        100);
            }
        }

        // console.log("Proposal odds :");
        // for (uint8 i = 0; i < _market; i++) {
        //     console.log(" ", pOdds[i]);
        // }

        uint256[] memory cOdds = Newton.adjustOddsWithMargin(
            pOdds,
            margin,
            multiplier
        );
        for (uint8 i = 0; i < _market; i++) {
            console.log("     ", cOdds[i]);
        }
        return cOdds[_outcome];
    }

    function calculateOdd(
        uint256 _amount,
        uint8 _outcome,
        uint8 _eventId
    ) public view returns (uint256 _odds) {
        EventInfo storage eventInfo = eventInfos[_eventId];
        _odds =
            ((eventInfo.reinforcement + _amount) * multiplier) /
            ((eventInfo.reinforcement * eventInfo.ratioWin[_outcome]) /
                multiplier /
                100 +
                _amount);
        uint256 _margin;
        if (eventInfo.totalNetBet == 0) {
            _margin = margin / eventInfo.market;
        } else {
            _margin =
                ((((eventInfo.totalNetBet - eventInfo.NetBet[_outcome]) *
                    multiplier) /
                    (eventInfo.market - 1) /
                    (eventInfo.totalNetBet + _amount)) * margin) /
                multiplier;
        }
        _odds =
            (_odds * multiplier) /
            (multiplier + (_margin * _odds) / multiplier);
        console.log("     ", _odds);
    }

    function max(
        uint256[] memory numbers,
        uint256 number
    ) public pure returns (uint256) {
        require(numbers.length > 0);
        uint256 maxNumber;
        for (uint256 i = 0; i < numbers.length; i++) {
            if (numbers[i] > maxNumber) maxNumber = numbers[i];
        }
        if (maxNumber < number) maxNumber = number;
        return (maxNumber);
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
    error EventNotExits();
}
