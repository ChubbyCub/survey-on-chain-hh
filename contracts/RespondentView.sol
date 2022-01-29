// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;
import "./Survey.sol";
import "./semaphore/Ownable.sol";

contract RespondentView is Ownable {
    struct RespondentViewWrapper {
        ISurvey[] surveys;
        string[] surveyNames;
        mapping(ISurvey => bool) surveyMap;
    }

    RespondentViewWrapper respondentViewWrapper;

    address respondentAddress;

    constructor(address _respondentAddress) Ownable() {
        respondentAddress = _respondentAddress;
    }

    function getSurveyNames() public view returns (string[] memory) {
        require(msg.sender == respondentAddress, "Only participant can view survey names");
        return respondentViewWrapper.surveyNames;
    }

    function getAllSurveyAddresses() public view returns (ISurvey[] memory) {
        require(msg.sender == respondentAddress, "Only participant can view survey addresses");
        return respondentViewWrapper.surveys;
    }

    function openSurvey(address surveyAddress, uint256 identityCommitment) public {
        require(msg.sender == respondentAddress, "Only participant can open survey instance");
    }

    function submitSurveyResponse() public {
        require(msg.sender == respondentAddress, "Only participant can submit survey response");
    }

    function addSurvey(ISurvey newSurvey) public onlyOwner {
        respondentViewWrapper.surveys.push(newSurvey);
        respondentViewWrapper.surveyMap[newSurvey] = true;
        respondentViewWrapper.surveyNames.push(newSurvey.getSurveyName());
    }
}