//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

struct User {
    address userAddress;
    string nickname;
    string country;
    uint birthdateYear;
    string description;
    string[] interests;
    string profileImageURL;
    bool isSet;
}

struct Project {
    uint id;
    uint createdAt;
    string projectDetails;
    // string title;
    // string description;
    // string category;
    uint deadline;
    // string agreementURL;
    // string[] projectImages;

    string testType;
    string questions;

    string restrictionsDetail;
    // uint minAge;
    // uint maxAge;
    // string targetCountry;
    uint maxTestersQuantity;
    // uint minimumCompletionsRestriction;
    uint investment;

    uint status; // 0: INCOMPLETE | 1: OPENED | 2: CLOSED
}

struct TestEnrollment {
    uint id;
    uint status; // 0: PENDING | 1: DONE
    string results;
}