// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;
import "./Survey.sol";
import "./semaphore/Ownable.sol";

contract SurveyResultsView is Ownable {

    struct SurveyResultsWrapper {
        Survey[] surveys;
        mapping(Survey => bool) surveyMap;
        mapping(Survey => uint) surveyIndices;
    }

    SurveyResultsWrapper surveyResultsWrapper;
    uint currSurvey;

    constructor() {
        currSurvey = 0;
    }

    function openSurveyResults(Survey _survey) public onlyOwner returns (string[] memory surveyQuestions, uint[] memory surveyScores) {
        require(surveyResultsWrapper.surveyMap[_survey], "Survey does not exist");

        uint surveyIndex = surveyResultsWrapper.surveyIndices[_survey];
        return surveyResultsWrapper.surveys[surveyIndex].getSurveyScores();
    }
    
    // Retrieves all survey results
    function getAllSurveys() public view onlyOwner returns (Survey[] memory ) {
        return surveyResultsWrapper.surveys;
    }

    function addSurvey(Survey newSurvey) public onlyOwner {
        surveyResultsWrapper.surveys.push(newSurvey);
        surveyResultsWrapper.surveyMap[newSurvey] = true;
        surveyResultsWrapper.surveyIndices[newSurvey] = currSurvey;
        currSurvey++;
    }
}