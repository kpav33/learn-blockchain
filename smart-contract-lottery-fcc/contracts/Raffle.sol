// Raffle

// Enter the lottery (paying some amount)
// Pick a random winner (verifiably random)
// Winner to be selected every X minutes -> completely automated

// Chainlink Oracle -> Randomness, Automated Execution (Chainlink keeper)

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

error Raffle__NotEnoughETHEntered();

contract Raffle {
    /* State Variable */
    // Make it immutable to save some gas
    uint256 private immutable i_entranceFee;
    // Must be payable, because one of the players will win the lottery and we will have to pay them
    address payable[] private s_players;

    // We want the entrance fee to be configurable so we set it up in the constructor
    constructor(uint256 entranceFee) {
        i_entranceFee = entranceFee;
    }

    function enterRaffle() public payable {
        // require (msg.value > i_entranceFee, "Not Enough ETH!")
        if (msg.value < i_entranceFee) {
            revert Raffle__NotEnoughETHEntered();
        }
        // Keep track of all players that enter the lottery
        s_players.push(payable(msg.sender));
        // Emit an event when we update a dynamic array or mapping
    }

    // function pickRandomWinner() {}

    // Show entrance fee value
    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }

    // Show player address
    function getPlayer(uint256 index) public view returns (address) {
        return s_players[index];
    }
}
