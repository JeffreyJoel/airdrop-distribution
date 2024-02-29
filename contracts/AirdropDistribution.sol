// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract AirdropDistribution {

    //Custom errors
    error ADDRESS_ZERO_DETECTED();
    error ADDRESS_ALREADY_EXISTS();

    struct User {
        uint id;
        bool isRegistered;
        bool hasFollowed;
        bool hasLikedPost;
        uint points;
    }

    uint trackUserId; 


    mapping(address => User) users;

    uint[] participantsId;

    constructor() {

    }

    function registerUser() external{
        // check address zero;
        //check if the address has been registered
        if(msg.sender == address(0)){
            revert ADDRESS_ZERO_DETECTED();
        }

         if(users[msg.sender].isRegistered == true){
            revert ADDRESS_ALREADY_EXISTS();
        }      

        uint _userId = trackUserId;
        User memory _user =  User(_userId, false, false, false, 0);

        users[msg.sender] = _user;

        trackUserId = trackUserId + 1;
    }



    
}
