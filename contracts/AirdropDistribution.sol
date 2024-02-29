// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AirdropDistribution is VRFConsumerBaseV2 {
    IERC20 tokenA;
    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);

    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomWords;
    }
    mapping(uint256 => RequestStatus) public s_requests; /* requestId --> requestStatus */
    VRFCoordinatorV2Interface COORDINATOR;

    // Your subscription ID.
    uint64 s_subscriptionId;

    // past requests Id.
    uint256[] public requestIds;
    uint256 public lastRequestId;

    bytes32 immutable keyHash;
    address public immutable linkToken;

    uint32 callbackGasLimit = 150000;

    uint16 requestConfirmations = 3;
    uint32 numWords = 1;
    uint256 public randomWordsNum;

    //Custom errors
    error ADDRESS_ZERO_DETECTED();
    error ADDRESS_ALREADY_EXISTS();
    error AIRDROP_HAS_ENDED();
    error ACTION_HAS_ALREADY_BEEN_DONE();

    struct User {
        uint256 id;
        bool isRegistered;
        bool hasFollowed;
        bool hasLikedPost;
        uint256 points;
        bool hasReachedMinEntryPoint;
    }

    uint256 trackUserId;

    uint8 constant followPoints = 5;
    uint8 constant sharePoints = 5;
    uint8 constant likePoints = 5;
    uint256 constant entryPoint = 10;

    bool isAirdropEnded = false;

    mapping(address => User) users;

    uint256[] participantsId;
    address[] participantsAddress;

    constructor(
        uint64 subscriptionId,
        address _linkToken,
        address _tokenA
    ) VRFConsumerBaseV2(0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D) {
        COORDINATOR = VRFCoordinatorV2Interface(
            0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D
        );
        s_subscriptionId = subscriptionId;

        keyHash = 0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15; // we alread set this
        linkToken = _linkToken;
        tokenA = IERC20(_tokenA);
    }

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

        uint256 _userId = trackUserId + 1;
        User memory _user = User(_userId, false, false, false, 0, false);

        users[msg.sender] = _user;

        trackUserId = trackUserId + 1;
    }

    function likePost() external {
        _userAlreadyExists();

        if (users[msg.sender].hasLikedPost == true) {
            revert ACTION_HAS_ALREADY_BEEN_DONE();
        }
        users[msg.sender].hasLikedPost = true;
        users[msg.sender].points = users[msg.sender].points + likePoints;
        _trackUserPoints();
    }

    function follow() external {
        _userAlreadyExists();

        if (users[msg.sender].hasFollowed == true) {
            revert ACTION_HAS_ALREADY_BEEN_DONE();
        }
        users[msg.sender].hasFollowed = true;
        users[msg.sender].points = users[msg.sender].points + followPoints;
        _trackUserPoints();
    }

    function distributeRewards() private {
        //Disburse Code
        if (participantsId.length == 10) {
            isAirdropEnded = true;
            //handle Disburse with chainlink vrf and IERC20
            uint256 requestId = requestRandomWords();

            uint256 winnerIndex = randomWordsNum % participantsId.length;
            address winnerAddress = participantsAddress[winnerIndex];
            uint256 amount = 10 * users[winnerAddress].points;
            tokenA.transferFrom(msg.sender, winnerAddress, amount);
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
                participantsAddress.push(msg.sender);
                participantsId.push(users[msg.sender].id);
            }
        }
    }

    function requestRandomWords() public returns (uint256 requestId) {
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);
        return requestId; // requestID is a uint.
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(s_requests[_requestId].exists, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        randomWordsNum = _randomWords[0]; // Set array-index to variable, easier to play with
        emit RequestFulfilled(_requestId, _randomWords);
    }

    // to check the request status of random number call.
    function getRequestStatus(uint256 _requestId)
        external
        view
        returns (bool fulfilled, uint256[] memory randomWords)
    {
        require(s_requests[_requestId].exists, "request not found");
        RequestStatus memory request = s_requests[_requestId];
        return (request.fulfilled, request.randomWords);
    }
}
