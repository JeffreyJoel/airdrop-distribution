// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract AirdropDistribution {
    //Custom errors
    error ADDRESS_ZERO_DETECTED();
    error ADDRESS_ALREADY_EXISTS();
    error AIRDROP_HAS_ENDED();

    struct User {
        uint id;
        bool isRegistered;
        bool hasFollowed;
        bool hasLikedPost;
        uint points;
        bool hasReachedMinEntryPoint;
    }

    uint trackUserId;

    uint8 constant followPoints = 5;
    uint8 constant sharePoints = 5;
    uint8 constant likePoints = 5;
    uint constant entryPoint = 10;

    bool isAirdropEnded = false;

    mapping(address => User) users;

    uint[] participantsId;

    constructor() {}

    function registerUser() external {
        // check address zero;
        //check if the address has been registered
        if (isAirdropEnded = true) {
            revert AIRDROP_HAS_ENDED();
        }
        if (msg.sender == address(0)) {
            revert ADDRESS_ZERO_DETECTED();
        }
        _userAlreadyExists();

        uint _userId = trackUserId + 1;
        User memory _user = User(_userId, false, false, false, 0, false);

        users[msg.sender] = _user;

        trackUserId = trackUserId + 1;
    }

    function likePost() external {
        _userAlreadyExists();
        users[msg.sender].hasLikedPost = true;
        users[msg.sender].points = users[msg.sender].points + likePoints;
        _trackUserPoints();
    }

    function follow() external {
        _userAlreadyExists();
        users[msg.sender].hasFollowed = true;
        users[msg.sender].points = users[msg.sender].points + followPoints;
        _trackUserPoints();
    }

    function distributeRewards() private {
        //Disburse Code
        if (participantsId.length == 10) {
            //handle Disburse with chainlink vrf and IERC20
            isAirdropEnded = true;
        }
    }
 
    function _userAlreadyExists() private view {
        if (users[msg.sender].isRegistered == true) {
            revert ADDRESS_ALREADY_EXISTS();
        }
    }

    function _trackUserPoints() private {
        if (users[msg.sender].hasReachedMinEntryPoint) {
            if (users[msg.sender].points >= entryPoint) {
                users[msg.sender].hasReachedMinEntryPoint = true;
                participantsId.push(users[msg.sender].id);
            }
        }
    }
}
