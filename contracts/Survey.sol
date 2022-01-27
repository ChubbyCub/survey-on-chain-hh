// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./semaphore/Semaphore.sol";
import "./Utils.sol";
import "./semaphore/Ownable.sol";
import "hardhat/console.sol";

interface ISurvey{
    function getSurveyScores() external 
        returns(string[] memory _surveyQuestions, uint[] memory _surveyScores);
}

interface ISemaphore {
    function addExternalNullifier(uint232 _externalNullifier) external;
    function broadcastSignal(
        bytes memory _signal,
        uint256[8] memory _proof,
        uint256 _root,
        uint256 _nullifiersHash,
        uint232 _externalNullifier
    ) external;
    function transferOwnership(address newOwner) external;
    function insertIdentity(uint256 _identityCommitment) external;
}

contract Survey is Ownable {
    // surveyQuestionsMap and surveyQuestions need to be kept in sync at all times.
    // map to accelerate look up.
    // Survey _question wrapper
    struct SurveyQuestionsWrapper {
        mapping(string => bool) surveyQuestionsMap;
        string[] surveyQuestions;
    }
    // name of this survey
    string surveyName;
    // Semaphore contract unique to this survey
    ISemaphore semaphore;

    uint232 externalNullifier;
    uint surveyCreationTime;
    uint surveyTimeout;
    address[] participants;
    // stores all response scores in a map
    mapping(string => uint[]) private questionToScoreList;
    uint private numRespondents;
    uint[] private surveyScores;
    SurveyQuestionsWrapper private surveyQuestionsWrapper;

    // control contract to update survey scores only when necessary
    bool shouldUpdateSurveyScores;

    modifier hasSemaphore() {
        require(semaphore != ISemaphore(address(0)), "must have semaphore");
        _;
    }
    
    constructor(
        string[] memory _surveyQuestions, 
        address[] memory _participants, 
        uint _surveyTimeout,
        string memory _surveyName,
        address _semaphoreAddress
    ) Ownable() {
        console.log("Entering constructor for survey...");
        surveyQuestionsWrapper.surveyQuestions = _surveyQuestions;
        for (uint i = 0; i < _surveyQuestions.length; i++) {
            string memory question = _surveyQuestions[i];
            surveyQuestionsWrapper.surveyQuestionsMap[question] = true;
        }
        surveyTimeout = _surveyTimeout;
        surveyCreationTime = block.timestamp;
        semaphore = ISemaphore(_semaphoreAddress);
        participants = _participants;
        surveyName = _surveyName;
    }

    function addExternalNullifierAndInsertIdentity() public onlyOwner {
        console.log("addExternalNullifierAndInsertIdentity start");
        bytes memory encoded = abi.encode(address(this));
        externalNullifier = uint232(uint256(keccak256(encoded)));
        semaphore.addExternalNullifier(externalNullifier);
        for(uint i = 0; i < participants.length; i++) {
            uint256 encodedParticipantAddress = uint256(keccak256(abi.encode(participants[i])));
            semaphore.insertIdentity(encodedParticipantAddress);
        }
        console.log("addExternalNullifierAndInsertIdentity finish");
    }

    function verifySurveySubmission(string[] memory questions, uint[] memory scores) private view returns (bool) {
        // check that the response size is equal to the number of questions
        if (questions.length != surveyQuestionsWrapper.surveyQuestions.length) {
            return false;
        }
        if (scores.length != surveyQuestionsWrapper.surveyQuestions.length) {
            return false;
        }
        // check that the responded questions are in the list of survey questions
        for (uint i = 0; i < questions.length; i++) {
            string memory question = questions[i];
            if (!surveyQuestionsWrapper.surveyQuestionsMap[question]) {
                return false;
            }
        }
        return true;
    }

    // Store survey results by questions
    // we cannot update the average score right away becaue solidty doesn't support
    // floating points. Rounding immediately will cause rounding errors to be too large
    // when there are lots of respondents
    // Both surveyResponse and surveyResponseBytes are needed for ease of serializing and
    // deserializing
    // Need to improve this function for survey privacy
    function updateSurveyResult(
        string[] memory questions,
        uint[] memory scores,
        bytes memory surveyResponseBytes,
        uint256[8] memory _proof,
        uint256 _root,
        uint256 _nullifiersHash)
    public hasSemaphore {
        require(!verifySurveySubmission(questions, scores), "Submission is incorrect");
        semaphore.broadcastSignal(
            surveyResponseBytes, 
            _proof, 
            _root, 
            _nullifiersHash, 
            externalNullifier
        );
        numRespondents++;
        for(uint i = 0; i < surveyQuestionsWrapper.surveyQuestions.length; i++) {
            string memory question = surveyQuestionsWrapper.surveyQuestions[i];
            uint score = scores[i];
            questionToScoreList[question].push(score);
        }
        shouldUpdateSurveyScores = true;
    }

    // This function will be used to retrieve results
    function calcAverageScorePerQuestion() private {
        if (!shouldUpdateSurveyScores || block.timestamp > surveyCreationTime + surveyTimeout) {
            return;
        }
        // remove all average scores stored in array
        delete surveyScores;
        // loop thru survey questions and calculate average score per
        // _question then push the average into averageScores array
        for(uint i = 0; i < surveyQuestionsWrapper.surveyQuestions.length; i++) {
            string memory question = surveyQuestionsWrapper.surveyQuestions[i];
            uint averageScore = Utils.getArraySum(questionToScoreList[question]) / numRespondents;
            surveyScores.push(averageScore);
        }
        shouldUpdateSurveyScores = false;
    }

    function getSurveyScores() public onlyOwner hasSemaphore returns(string[] memory _surveyQuestions, uint[] memory _surveyScores) {
        calcAverageScorePerQuestion();
        if (block.timestamp > surveyCreationTime + surveyTimeout) {
            uint[] memory emptySurveyScores;
            return (surveyQuestionsWrapper.surveyQuestions, emptySurveyScores);
        }
        return (surveyQuestionsWrapper.surveyQuestions, surveyScores);
    }

    // Will be updated to only allow permitted users to see survey questions
    function getSurveyQuestions() public view returns (string[] memory)  {
        return surveyQuestionsWrapper.surveyQuestions;
    }
}
