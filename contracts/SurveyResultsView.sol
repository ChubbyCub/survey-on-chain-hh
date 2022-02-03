// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;
import "./Survey.sol";
import "./semaphore/Ownable.sol";


contract SurveyResultsView is Ownable {

    struct SurveyResultsWrapper {
        ISurvey[] surveys;
        string[] surveyNames;
        mapping(ISurvey => bool) surveyMap;
    }

    SurveyResultsWrapper surveyResultsWrapper;
    address surveyor;

    constructor(address _surveyor) {
        surveyor = _surveyor;
    }
    
    // Retrieves all survey results
    function getAllSurveys() public view returns (string[] memory) {
        require(surveyor == msg.sender, "Only surveyors can view surveys");
        return surveyResultsWrapper.surveyNames;
    }

    function getAllSurveyAddresses() public view returns (ISurvey[] memory) {
        require(surveyor == msg.sender, "Only surveyors can view surveys");
        return surveyResultsWrapper.surveys;
    }

    function addSurvey(ISurvey newSurvey) public onlyOwner {
        surveyResultsWrapper.surveys.push(newSurvey);
        surveyResultsWrapper.surveyNames.push(newSurvey.getSurveyName());
        surveyResultsWrapper.surveyMap[newSurvey] = true;
    }
}