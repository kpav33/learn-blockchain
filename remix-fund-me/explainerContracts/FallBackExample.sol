// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract FallbackExample {
    uint256 public result;

    // Fallback function must be declared as external.
    // Similar to receive function, but can also work when data is sent with the transaction
    fallback() external payable {
        result = 1;
    }

    // Whenever we send ETH or make a transaction to this contract, without any data associated, the receive function will be triggered
    receive() external payable {
        result = 2;
    }
}

    // Explainer from: https://solidity-by-example.org/fallback/
    // Ether is sent to contract
    //      is msg.data empty?
    //          /   \ 
    //         yes  no
    //         /     \
    //    receive()?  fallback() 
    //     /   \ 
    //   yes   no
    //  /        \
    //receive()  fallback()