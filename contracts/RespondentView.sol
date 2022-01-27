// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;
import "./Survey.sol";
import "./semaphore/Ownable.sol";

contract RespondentView is Ownable {
    struct RespondentViewWrapper {
        ISurvey[] surveys;
        mapping(ISurvey => bool) surveyMap;
    }

    RespondentViewWrapper respondentViewWrapper;

    constructor() Ownable() {}

    event surveyNames(
        string message
    );

    event open(
        string message
    );
    
    event submit(
        string message
    );

    function getSurveyNames() public {
        emit surveyNames("Called get survey names");
    }

    function openSurvey(address surveyAddress, uint256 identityCommitment) public {
        emit open("Called open survey");
    }

    function submitSurveyResponse() public {
        emit submit("Called submit survey response");
    }

    function addSurvey(address caller, ISurvey newSurvey) public onlyOwner {
        respondentViewWrapper.surveys.push(newSurvey);
        respondentViewWrapper.surveyMap[newSurvey] = true;
    }
}