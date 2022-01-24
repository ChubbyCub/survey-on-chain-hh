// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Survey.sol";

contract SurveyFactory {
    function createNewSurvey(
        string[] calldata _surveyQuestions, 
        address[] calldata _participants, 
        uint _surveyTimeout,
        string calldata _surveyName,
        address _semaphoreAddress
    ) public returns (Survey) {
        return new Survey(
            _surveyQuestions,
            _participants,
            _surveyTimeout,
            _surveyName,
            _semaphoreAddress
        );
    }
}