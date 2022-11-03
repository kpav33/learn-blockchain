// Raffle

// Enter the lottery (paying some amount)
// Pick a random winner (verifiably random)
// Winner to be selected every X minutes -> completely automated

// Chainlink Oracle -> Randomness, Automated Execution (Chainlink keeper)

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";

error Raffle__NotEnoughETHEntered();
error Raffle__TransferFailed();
error Raffle__NotOpen();
error Raffle__UpkeepNotNeeded(uint256 currentBalance, uint256 numPlayers, uint256 raffleState);

/** @title A sample Raffle Contract
 *  @author John Smith
 *  @notice This contract is for creating an untamperable decentralize smart contract
 *  @dev This implements Chainlink VRF v2 and Chainlink Keepers
 */
contract Raffle is VRFConsumerBaseV2, KeeperCompatibleInterface {
    /* Type Declarations */
    enum RaffleState {
        OPEN,
        CALCULATING
    } // uint256 0 = OPEN, 1 = CALCULATING

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
    uint256 private immutable i_interval;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    // Lottery Variables
    address private s_recentWinner;
    RaffleState private s_raffleState;
    uint256 private s_lastTimeStamp;

    /* Events */
    event RaffleEnter(address indexed player);
    event RequestedRaffWinner(uint256 indexed requestId);
    event WinnerPicked(address indexed winner);

    /* Functions */
    // We want the entrance fee to be configurable so we set it up in the constructor
    // VRFConsumerBaseV2 need to pass it, this is the address of the contract that does the random number verification
    constructor(
        address vrfCoordinatorV2, // contract address, will need to deploy some mocks
        uint256 entranceFee,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit,
        uint256 interval
    ) VRFConsumerBaseV2(vrfCoordinatorV2) {
        i_entranceFee = entranceFee;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        s_raffleState = RaffleState.OPEN;
        s_lastTimeStamp = block.timestamp;
        i_interval = interval;
    }

    function enterRaffle() public payable {
        // require (msg.value > i_entranceFee, "Not Enough ETH!")
        if (msg.value < i_entranceFee) {
            revert Raffle__NotEnoughETHEntered();
        }
        // Only let users play the lottery if it is open
        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle__NotOpen();
        }
        // Keep track of all players that enter the lottery
        s_players.push(payable(msg.sender));
        // Emit an event when we update a dynamic array or mapping
        // Named events with the function name reversed
        emit RaffleEnter(msg.sender);
    }

    /**
     * @dev This is the function that the Chainlink Keeper nodes call
     * they look for `upkeepNeeded` to return True.
     * the following should be true for this to return true:
     * 1. The time interval has passed between raffle runs.
     * 2. The lottery is open.
     * 3. The contract has ETH.
     * 4. Implicity, your subscription is funded with LINK.
     */
    // Having checkData be type bytes allows for this data to be essentialy anything you want
    function checkUpkeep(
        bytes memory /*checkData*/
    )
        public
        override
        returns (
            // view
            bool upkeepNeeded,
            bytes memory /* performData */
        )
    {
        // Check if lottery is open
        bool isOpen = (RaffleState.OPEN == s_raffleState);
        // block.timestamp - last block timestamp > interval
        // Check if time interval has passed
        bool timePassed = ((block.timestamp - s_lastTimeStamp) > i_interval);
        // Check if there are players participating in the lottery
        bool hasPlayers = (s_players.length > 0);
        // Check if lottery has balance
        bool hasBalance = address(this).balance > 0;
        // If upkeepNeeded returns true its time to start a new lottery
        upkeepNeeded = (isOpen && timePassed && hasPlayers && hasBalance);
        // return (upkeepNeeded, "0x0");
    }

    /**
     * @dev Once `checkUpkeep` is returning `true`, this function is called
     * and it kicks off a Chainlink VRF call to get a random winner.
     */
    // External functions are a bit cheaper, because Solidity knows the contract can't call them, can only be called from the "outside"
    // function requestRandomWinner() external {
    // Replace requestRandomWinner function with performUpkeep function from chainlink keepers
    function performUpkeep(
        bytes calldata /* performData */
    ) external override {
        // Only execute the function if upkeepeNeeded is true
        (bool upkeepNeeded, ) = checkUpkeep("");
        if (!upkeepNeeded) {
            revert Raffle__UpkeepNotNeeded(
                address(this).balance,
                s_players.length,
                uint256(s_raffleState)
            );
        }

        // Disable lottery while a winner is being determined
        s_raffleState = RaffleState.CALCULATING;
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

    /**
     * @dev This is the function that Chainlink VRF node
     * calls to send the money to the random winner.
     */
    // This function comes from chainlinks VRFConsumerBaseV2 contract, where it is marked as an virtual function, which means it expected to be overridden
    function fulfillRandomWords(
        uint256, /* requestId */ // We comment out the requestId, because we don't actually use it, but since we inherit the function from chainlink contract we have to keep it as parameter, despite not using it
        uint256[] memory randomWords
    ) internal override {
        // s_players size 10
        // randomNumber 202
        // 202 % 10 = 2

        // randomWords at index 0, because we set it up to only receive back one random word (number)
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;
        // After winner is selected, open the lottery again
        s_raffleState = RaffleState.OPEN;
        // After winner is picked, reset the players array and the timestamp
        s_players = new address payable[](0);
        s_lastTimeStamp = block.timestamp;

        // Send lottery award to the winner
        (bool success, ) = recentWinner.call{value: address(this).balance}("");
        // Error if  transaction failes
        if (!success) {
            revert Raffle__TransferFailed();
        }
        emit WinnerPicked(recentWinner);
    }

    /* View / Pure functions */
    /** Getter Functions */

    // Show entrance fee value
    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }

    // Show player address
    function getPlayer(uint256 index) public view returns (address) {
        return s_players[index];
    }

    // Return last winner address
    function getRecentWinner() public view returns (address) {
        return s_recentWinner;
    }

    function getRaffleState() public view returns (RaffleState) {
        return s_raffleState;
    }

    function getNumWords() public pure returns (uint256) {
        return NUM_WORDS;
    }

    function getNumberOfPlayers() public view returns (uint256) {
        return s_players.length;
    }

    function getLastTimeStamp() public view returns (uint256) {
        return s_lastTimeStamp;
    }

    function getRequestConfirmations() public pure returns (uint256) {
        return REQUEST_CONFIRMATIONS;
    }

    function getInterval() public view returns (uint256) {
        return i_interval;
    }
}
