// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// With versions of Solidity above 0.8.0 this checking is done automatically and you don't need any special library for it

contract SafeMathTester{
    uint8 public bigNumber = 255; // checked

    function add() public {
        // By using unchecked keyword, you can revert back to the unchecked version of Solidity
        // The unchecked keyword is sometimes used because it makes you more gas efficient
        // Unchecked should only be used for values where you are absolutely certain, they won't go over the limit
        unchecked {bigNumber = bigNumber + 1;}
    }
}