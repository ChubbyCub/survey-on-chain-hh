// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;
import "./RespondentView.sol";
import "./SurveyResultsView.sol";
import "./Survey.sol";
import "hardhat/console.sol";

contract Platform {
    mapping(address => RespondentView) respondentViews;
    mapping(address => SurveyResultsView) surveyResultViews;

    mapping(address => ISurvey[]) surveyBuffer;

    event create(string message);
    event complete(string message);

    function signInAsSurveyor() public {
        if (surveyResultViews[msg.sender] == SurveyResultsView(address(0))) {
            // create one instance of survey result view for a creator
            createSurveyResultView(msg.sender);
        }
    }

    function signInAsParticipant() public {
        if (respondentViews[msg.sender] == RespondentView(address(0))) {
            // create one instance of respondent view for a participant
            createRespondentView(msg.sender);
        }
        ISurvey[] memory surveys = surveyBuffer[msg.sender];
        for (uint i = 0; i < surveys.length; i++) {
            respondentViews[msg.sender].addSurvey(surveys[i]);
        }
        delete surveyBuffer[msg.sender];
    }

    // Survey creator add the contract they created to the platform
    function addExistingSurvey(
        address[] memory _participants,
        address newSurveyAddress
    ) public returns (address) {
        signInAsSurveyor();
        SurveyResultsView resultsView = surveyResultViews[msg.sender];

        resultsView.addSurvey(ISurvey(newSurveyAddress));
        for (uint i = 0; i < _participants.length; i++) {
            address participant = _participants[i];
            surveyBuffer[participant].push(ISurvey(newSurveyAddress));
        }

        return address(newSurveyAddress);
    }

    function createSurveyResultView(address surveyor) private {
        SurveyResultsView resultsView = new SurveyResultsView(surveyor);
        surveyResultViews[surveyor] = resultsView;
    }

    function createRespondentView(address participant) private {
        RespondentView respondentView = new RespondentView(participant);
        respondentViews[participant] = respondentView;
    }

    function getSurveyorsResultAddress() public view returns (address) {
        return address(surveyResultViews[msg.sender]);
    }

    function getRespondentViewAddress() public view returns (address) {
        return address(respondentViews[msg.sender]);
    }
}