//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
pragma abicoder v2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";
import "./MidasStructs.sol";

contract MidasTest is Ownable {
    /// *** COUNTERS *** ///
    using Counters for Counters.Counter;
    Counters.Counter private _projectId;
    Counters.Counter private _testEnrollmentId;

    /// *** VARIABLES *** ///

    uint public midasFee = 10 ether;
    uint public minimumInvestment = 50 ether;
    address[] wallets;

    /// *** MAPPINGS *** ///

    mapping (address => User) private _userInfo;
    mapping (address => uint) public userCompletedTestsCount;
    
    mapping (uint => Project) private _projectInfo;
    mapping (uint => address) public projectToOwner;
    mapping (address => uint) public ownerProjectCount;
    mapping (uint => uint) public projectRemainingInvestment;

    mapping (uint => TestEnrollment) private _testEnrollment;
    mapping (uint => address) public testEnrollmentToOwner;
    mapping (uint => uint) public testEnrollmentToProject;
    mapping (address => uint) public ownerTestEnrollmentCount;
    mapping (uint => uint) public projectTestEnrollmentCount;

    /// *** EVENTS *** ///

    constructor () {}

    /// *** MIDAS FEE *** ///

    function setMidasFee(uint _newFee) external onlyOwner {
        midasFee = _newFee;
    }

    function getMidasFee() external view returns (uint) {
        return midasFee;
    }

    /// *** USER INFO *** ///

    function getUserInfo(address _userAddress) external view returns (User memory) {
        return _userInfo[_userAddress];
    }

    function getProjectOwnerName(uint _projectIdToGetOwnerName) external view returns (string memory) {
        return _userInfo[projectToOwner[_projectIdToGetOwnerName]].nickname;
    }

    function getEnrollmentUserData(uint _testEnrollmentIdToGetUserData) external view returns (string memory, uint, uint, address) {
        require(msg.sender == projectToOwner[testEnrollmentToProject[_testEnrollmentIdToGetUserData]], "A01");
        return (
            _userInfo[testEnrollmentToOwner[_testEnrollmentIdToGetUserData]].nickname,
            _userInfo[testEnrollmentToOwner[_testEnrollmentIdToGetUserData]].birthdateYear,
            userCompletedTestsCount[testEnrollmentToOwner[_testEnrollmentIdToGetUserData]],
            testEnrollmentToOwner[_testEnrollmentIdToGetUserData]
        );
    }

    function setUserInfo(
        string memory _nickname,
        string memory _country,
        uint _birthdateYear,
        string memory _description,
        string[] memory _interests,
        string memory _profileImageURL
    ) external returns (string memory) {

        bool exists = false;

        if (_userInfo[msg.sender].isSet) {
            exists = true;
        } else {
            wallets.push(msg.sender);
        }

        _userInfo[msg.sender] = User(msg.sender, _nickname, _country, _birthdateYear, _description, _interests, _profileImageURL, true);

        if (exists) {
            return "Successfully updated!";
        } else {
            return "Successfully created!";
        }

    }

    /// *** PROJECTS *** ///

    function getProjectInfo(uint _projectIdToGet) external view returns (Project memory) {
        return _projectInfo[_projectIdToGet];
    }

    function getTestEnrollmentProjectInfo(uint _testEnrollmentIdToGetProject) external view returns (Project memory) {
        return _projectInfo[testEnrollmentToProject[_testEnrollmentIdToGetProject]];
    }

    function getUserCreatedProjects() external view returns (uint[] memory) {
        uint[] memory result = new uint[](ownerProjectCount[msg.sender]);

        uint counter = 0;
        for (uint i = 0; i < _projectId.current(); i++ ) {
            if (projectToOwner[i] == msg.sender) {
                result[counter] = i;
                counter++;
            }
        }

        return result;
    }

    function getAllProjects() external view returns (uint[] memory) {
        uint[] memory result = new uint[](_projectId.current());

        uint counter = 0;
        for (uint i = 0; i < _projectId.current(); i++) {
            result[counter] = i;
            counter++;
        }

        return result;
    }

    function createProject(
        uint _createdAt,
        string memory _projectDetails,
        // string memory _title,
        // string memory _description,
        // string memory _category,
        uint _deadline,
        // string memory _agreementURL,
        // string[] memory _projectImages,
        string memory _testType,
        string memory _questions,
        string memory _restrictionsDetail,
        // uint _minAge,
        // uint _maxAge,
        // string memory _targetCountry,
        uint _maxTestersQuantity,
        // uint _minimumCompletionsRestriction,
        uint _investment
    ) public {
        require(_userInfo[msg.sender].isSet, "M01");

        _projectInfo[_projectId.current()] = Project(
            _projectId.current(),
            _createdAt,
            _projectDetails,
            // _title,
            // _description, 
            // _category, 
            _deadline, 
            // _agreementURL, 
            // _projectImages,
            _testType, 
            _questions,
            _restrictionsDetail, 
            // _minAge, 
            // _maxAge, 
            // _targetCountry, 
            _maxTestersQuantity, 
            // _minimumCompletionsRestriction,  
            _investment, 
            0
        );
        projectToOwner[_projectId.current()] = msg.sender;
        ownerProjectCount[msg.sender]++;

        _projectId.increment();
    }

    function updateProjectInfo(
        uint _projectIdToUpdate,
        string memory _projectDetails,
        // string memory _title,
        // string memory _description,
        // string memory _category,
        uint _deadline,
        // string memory _agreementURL,
        // string[] memory _projectImages,
        string memory _testType,
        string memory _questions,
        string memory _restrictionsDetail,
        // uint _minAge,
        // uint _maxAge,
        // string memory _targetCountry,
        uint _maxTestersQuantity,
        // uint _minimumCompletionsRestriction,
        uint _investment
    ) external {
        require(_projectIdToUpdate < _projectId.current(), "NE01");
        require(projectToOwner[_projectIdToUpdate] == msg.sender, "A02");
        require(_projectInfo[_projectIdToUpdate].status == 0, "C01");
        require(block.timestamp < _deadline, "D01");

        _projectInfo[_projectIdToUpdate] = Project(
            _projectIdToUpdate,
            _projectInfo[_projectIdToUpdate].createdAt,
            _projectDetails,
            // _title,
            // _description, 
            // _category, 
            _deadline, 
            // _agreementURL, 
            // _projectImages,
            _testType, 
            _questions,
            _restrictionsDetail,
            // _minAge, 
            // _maxAge, 
            // _targetCountry, 
            _maxTestersQuantity, 
            // _minimumCompletionsRestriction, 
            _investment, 
            0
        );
    }

    function projectKickOff(
        uint _projectIdToKickOff
    ) external payable {
        require(_projectInfo[_projectIdToKickOff].investment > minimumInvestment, "I01");
        require(msg.value >= (_projectInfo[_projectIdToKickOff].investment) + midasFee, "I02");
        require(_projectIdToKickOff < _projectId.current(), "NE01");
        require(projectToOwner[_projectIdToKickOff] == msg.sender, "A02");
        require(_projectInfo[_projectIdToKickOff].status == 0, "C01");
        require(block.timestamp < _projectInfo[_projectIdToKickOff].deadline, "D02");

        _projectInfo[_projectIdToKickOff].status = 1;

        projectRemainingInvestment[_projectIdToKickOff] = _projectInfo[_projectIdToKickOff].investment;
    }

    function closeProject(
        uint _projectIdToClose
    ) external {
        require(projectToOwner[_projectIdToClose] == msg.sender, "A03");
        require(_projectIdToClose < _projectId.current(), "NE02");
        require(block.timestamp < _projectInfo[_projectIdToClose].deadline, "D03");
        require(_projectInfo[_projectIdToClose].status == 1, "C02");

        for (uint i = 0; i < _testEnrollmentId.current(); i++) {
            if (testEnrollmentToProject[i] == _projectIdToClose) {
                if (_testEnrollment[i].status == 0) {
                    uint toPay = (_projectInfo[testEnrollmentToProject[i]].investment / _projectInfo[testEnrollmentToProject[i]].maxTestersQuantity);
                    payable(testEnrollmentToOwner[i]).transfer(toPay * 5 / 100);

                    projectRemainingInvestment[_projectIdToClose] -= toPay * 5 / 100;
                }
            }
        }

        payable(msg.sender).transfer(projectRemainingInvestment[_projectIdToClose]);
        projectRemainingInvestment[_projectIdToClose] -= projectRemainingInvestment[_projectIdToClose];

        _projectInfo[_projectIdToClose].status = 2;
    }

    /// *** TEST ENROLLMENT *** ///
    function enrollToProject(
        uint _projectIdToEnroll
    ) external {
        require(_userInfo[msg.sender].isSet, "M02");
        require(_projectInfo[_projectIdToEnroll].maxTestersQuantity >= projectTestEnrollmentCount[_projectIdToEnroll], "MXT01");
        require(projectToOwner[_projectIdToEnroll] != msg.sender, "A04");
        require(_projectInfo[_projectIdToEnroll].status == 1, "C03");

        _testEnrollment[_testEnrollmentId.current()] = TestEnrollment(_testEnrollmentId.current(), 0, "");
        testEnrollmentToOwner[_testEnrollmentId.current()] = msg.sender;
        testEnrollmentToProject[_testEnrollmentId.current()] = _projectIdToEnroll;
        ownerTestEnrollmentCount[msg.sender]++;
        projectTestEnrollmentCount[_projectIdToEnroll]++;

        _testEnrollmentId.increment();
    }

    function getUserEnrollments(address _address, bool _returnOnlyCompleted) external view returns (uint[] memory) {
        uint[] memory result = new uint[](ownerTestEnrollmentCount[_address]);

        uint counter = 0;
        for (uint i = 0; i < _testEnrollmentId.current(); i++) {
            if (testEnrollmentToOwner[i] == _address) {
                if (_returnOnlyCompleted) {
                    if (_testEnrollment[i].status == 1) {
                        result[counter] = i;
                        counter++;
                    }
                } else {
                    result[counter] = i;
                    counter++;
                }
            }
        }

        return result;
    }

    function updateEnrollmentResult(
        uint _testEnrollmentIdToUpdate,
        uint _status,
        string memory _results
    ) external {
        require(testEnrollmentToOwner[_testEnrollmentIdToUpdate] == msg.sender, "A05");

        require(_testEnrollment[_testEnrollmentIdToUpdate].status != 1, "C04");

        _testEnrollment[_testEnrollmentIdToUpdate].results = _results;

        if (_status == 1) {

            uint toPay = (
                _projectInfo[testEnrollmentToProject[_testEnrollmentIdToUpdate]].investment 
                / 
                _projectInfo[testEnrollmentToProject[_testEnrollmentIdToUpdate]].maxTestersQuantity);

            payable(msg.sender).transfer(toPay);

            _testEnrollment[_testEnrollmentIdToUpdate].status = _status;

            userCompletedTestsCount[msg.sender]++;

            projectRemainingInvestment[testEnrollmentToProject[_testEnrollmentIdToUpdate]] -= toPay;
        }
    }

    function getProjectResults(
        uint _projectIdToGetResults
    ) external view returns (uint[] memory) {
        require(_projectIdToGetResults < _projectId.current(), "NE03");
        require(projectToOwner[_projectIdToGetResults] == msg.sender, "A06");

        uint[] memory result = new uint[](projectTestEnrollmentCount[_projectIdToGetResults]);

        uint counter = 0;
        for (uint i = 0; i < _testEnrollmentId.current(); i++) {
            if (testEnrollmentToProject[i] == _projectIdToGetResults) {
                result[counter] = i;
                counter++;
            }
        }

        return result;
    }

    function getTestEnrollment(uint _testEnrollmentIdToGet) external view returns (TestEnrollment memory) {
        require(_testEnrollmentIdToGet < _testEnrollmentId.current(), "NE04");
        require(testEnrollmentToOwner[_testEnrollmentIdToGet] == msg.sender || projectToOwner[testEnrollmentToProject[_testEnrollmentIdToGet]] == msg.sender, "A07");
        return _testEnrollment[_testEnrollmentIdToGet];
    }

    /// *** STATISTICS *** ///
    function getUserCompletedTestsCount(address _address) external view returns (uint) {
        return userCompletedTestsCount[_address];
    }
 
}
