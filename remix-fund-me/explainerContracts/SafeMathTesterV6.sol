// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

// Prior to version 0.8.0 of Solidity uint and int were unchecked
// This meant that if you passed the upper limit of a number (for example limit of uin8 is 255) it would just wrap around and start again from the lowest possible number
// SafeMath library was popular for checking if you reached the max number of int or uint

contract SafeMathTester{
    uint8 public bigNumber = 255; // unchecked

    function add() public {
        bigNumber = bigNumber + 1;
    }
}