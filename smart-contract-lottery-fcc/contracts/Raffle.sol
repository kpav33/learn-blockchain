// Raffle

// Enter the lottery (paying some amount)
// Pick a random winner (verifiably random)
// Winner to be selected every X minutes -> completely automated

// Chainlink Oracle -> Randomness, Automated Execution (Chainlink keeper)

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

error Raffle__NotEnoughETHEntered();

contract Raffle is VRFConsumerBaseV2 {
    /* State Variable */
    // Make it immutable to save some gas
    uint256 private immutable i_entranceFee;
    // Must be payable, because one of the players will win the lottery and we will have to pay them
    address payable[] private s_players;
    // If a variable will be set up only once, it makes sense to make it private and immutable
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    /* Events */
    event RaffleEnter(address indexed player);
    event RequestedRaffWinner(uint256 indexed requestId);

    // We want the entrance fee to be configurable so we set it up in the constructor
    // VRFConsumerBaseV2 need to pass it, this is the address of the contract that does the random number verification
    constructor(
        address vrfCoordinatorV2,
        uint256 entranceFee,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2(vrfCoordinatorV2) {
        i_entranceFee = entranceFee;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
    }

    function enterRaffle() public payable {
        // require (msg.value > i_entranceFee, "Not Enough ETH!")
        if (msg.value < i_entranceFee) {
            revert Raffle__NotEnoughETHEntered();
        }
        // Keep track of all players that enter the lottery
        s_players.push(payable(msg.sender));
        // Emit an event when we update a dynamic array or mapping
        // Named events with the function name reversed
        emit RaffleEnter(msg.sender);
    }

    // External functions are a bit cheaper, because Solidity knows the contract can't call them, can only be called from the "outside"
    function requestRandomWinner() external {
        // Request the random number
        // Once we get it, do something with it
        // 2 transaction process
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane, //gasLane, maximum gas price you are willing to pay for a request in wei
            i_subscriptionId, // the subscription id that this contract uses for funding requests
            REQUEST_CONFIRMATIONS, // how many confirmations Chainlink node should wait before responding
            i_callbackGasLimit, // the limit for how much gas to use for the callback request to your contract's fulfillRandomWords() function
            NUM_WORDS // how many random numbers we want to get
        );
        emit RequestedRaffWinner(requestId);
    }

    // This function comes from chainlinks VRFConsumerBaseV2 contract, where it is marked as an virtual function, which means it expected to be overridden
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {}

    /* View / Pure functions */

    // Show entrance fee value
    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }

    // Show player address
    function getPlayer(uint256 index) public view returns (address) {
        return s_players[index];
    }
}
