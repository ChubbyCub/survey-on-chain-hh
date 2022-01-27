// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Survey.sol";
import "hardhat/console.sol";

contract SurveyFactory {
    function createNewSurvey(
        string[] calldata _surveyQuestions, 
        address[] calldata _participants, 
        uint _surveyTimeout,
        string calldata _surveyName,
        address _semaphoreAddress,
        address _surveyCreatorAddress
    ) public returns (Survey) {
        console.log("In factory...");
        Survey survey = new Survey(
            _surveyQuestions,
            _participants,
            _surveyTimeout,
            _surveyName,
            _semaphoreAddress
        );
        // ISemaphore sem = ISemaphore(_semaphoreAddress);
        survey.transferOwnership(_surveyCreatorAddress);
        console.log("before set up nullifier");
        console.log("after set up nullifier");
        return survey;
    }
}