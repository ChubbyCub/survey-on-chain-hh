// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;
import "./RespondentView.sol";
import "./SurveyResultsView.sol";
import "./SurveyFactory.sol";
import "./Survey.sol";
import "hardhat/console.sol";

contract Platform {
    mapping(address => RespondentView) respondentViews;
    mapping(address => SurveyResultsView) surveyResultViews;

    mapping(address => Survey[]) surveyBuffer;

    event create(string message);
    event complete(string message);

    SurveyFactory surveyFactory;

    constructor() {
        surveyFactory = new SurveyFactory();
    }

    function signInAsSurveyor() public {
        if (surveyResultViews[msg.sender] == SurveyResultsView(address(0))) {
            console.log("Elise testing logging");
            // create one instance of survey result view for a creator
            createSurveyResultView(msg.sender);
            console.log(address(surveyResultViews[msg.sender]));
            emit complete("Completed result view creation.");
        } else {
            console.log("Not creating duplicate view");
        }
    }

    function signInAsParticipant() public {
        if (respondentViews[msg.sender] == RespondentView(address(0))) {
            // create one instance of respondent view for a participant
            createRespondentView(msg.sender);
        }
        Survey[] memory surveys = surveyBuffer[msg.sender];
        for (uint i = 0; i < surveys.length; i++) {
            respondentViews[msg.sender].addSurvey(msg.sender, surveys[i]);
        }
        delete surveyBuffer[msg.sender];
    }

    function createSurvey(
        string[] calldata _surveyQuestions, 
        address[] calldata _participants, 
        uint _surveyTimeout,
        string calldata _surveyName,
        address _semaphoreAddress
    ) public returns (address) {
        signInAsSurveyor();
        emit create("Creating survey...");
        Survey newSurvey = surveyFactory.createNewSurvey(
            _surveyQuestions, _participants, 
            _surveyTimeout, 
            _surveyName,
            _semaphoreAddress
        );

        SurveyResultsView resultsView = surveyResultViews[msg.sender];
        resultsView.addSurvey(newSurvey);
        for (uint i = 0; i < _participants.length; i++) {
            address participant = _participants[i];
            surveyBuffer[participant].push(newSurvey);
        }

        return address(newSurvey);
    }

    function createSurveyResultView(address surveyor) private {
        emit create("Creating survey result view...");
        SurveyResultsView resultsView = new SurveyResultsView();
        surveyResultViews[surveyor] = resultsView;
        emit complete("Completed creating survey result view");
    }

    function createRespondentView(address participant) private {
        emit create("Creating respondent view...");
        RespondentView respondentView = new RespondentView();
        respondentViews[participant] = respondentView;
        emit complete("Completed creating respondent view");
    }

    function getSurveyorsResultAddress(address surveyor) public view returns (address) {
        return address(surveyResultViews[surveyor]);
    }
}