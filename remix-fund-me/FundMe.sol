// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./PriceConverter.sol";

// Create custom error
error NotOwner();

// Check Solidity by example website for library examples

// Import desired interface from npm, so that you don't have to write the interface code in your contract
// import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract FundMe {
    // Call a library so that its methods will be available on uin256 types
    using PriceConverter for uint256;

    // Blockchain oracle: Any device that interacts with the off-chain world to provide external data or computation to smart contracts
    // Multiply the value with 1e18 so that it is in the same format as the one that is returned by getConversionRate() function
    // uint256 public minimumUsd = 50 * 1e18;

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    // Could we make this constant?  /* hint: no! We should make it immutable! */
    // Variables that we set one time, but outside of the same line they are declared, we can mark as immutable
    // Usually you preface immutable values with i_
    // This also leads to gas savings, similarly to how constant keyword words
    address public /* immutable */ i_owner;
    // If you are assigning value to a variable only once, use the constant keyword
    // This way you save some gas
    uint256 public constant MINIMUM_USD = 50 * 10 ** 18;
    // Immutable and constants kewywords save gas, because instead of storing inside of a storage slot, they store directly inside of the byte code

    // Constructor gets called immediately when you deploy the contract
    constructor() {
        i_owner = msg.sender;
    }

    // To make a function payable add payable keyword to it
    function fund() public payable {
        // Want to be able to set a minimum fund amount in USD
        // Every transaction we send has nonce, gas price, gas limit, to, value, data and v,r,s fields
        // If function is marked as payable, you will have access to the msg.value field
        // Require for the value field be of at least 1 ETH value
        // If require isn't met the transaction will be cancelled and any prior work will be undone and remaining gas returned
        // require(getConversionRate(msg.value) >= minimumUsd, "Didn't send enough."); // 1e18 = 1 * 10 ** 18 === 1000000000000000000 => This much wei is one ETH
        // What is reverting? Undo any action before, and send remaining gas back
        // msg.sender is global keyword, where the address of whoever called the function is stored
        // When using a library you don't have to pass a value of ethAmount to getConversionRate function, despite it is needed
        // This is because msg.value is considered as the first parameter for any library functions
        // Need to deploy it on test net if you want the chainlink oracle to work, it doesn't work on Remix VM
        require(msg.value.getConversionRate() >= MINIMUM_USD, "Didn't send enough!");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = msg.value;
    }

    // function getPrice() public view returns (uint256) {
    //     // ABI
    //     // If you compile an Interface you will get the ABI of the contract
    //     // Address 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
    //     // The contract at the address should have all the functionality of the interface
    //     AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
    //     // If a function returns many different variables, you need to set something up to "catch" the variables
    //     // (uint80 roundId, int price, uint startedAt, uint timeStamp, uint80 answeredInRound) = priceFeed.latestRoundData();
    //     // Use empty commas for values you are not interested in and just get what you want
    //     (,int256 price,,,) = priceFeed.latestRoundData();
    //     // ETH in terms of USD
    //     // Multiply returned value with 10 decimals, because function returns value in 8 decimals places and we need 18, since 1 ETH = 1e18 wei
    //     return uint256(price * 1e10); // Convert to uint256 by type casting
    // }

    // function getConversionRate(uint256 ethAmount) public view returns (uint256) {
    //     uint256 ethPrice = getPrice();
    //     // Always multiply before your divide in Solidity
    //     uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
    //     return ethAmountInUsd;
    // }

    function getVersion() public view returns (uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        return priceFeed.version();
    }

    // A keyword that we can add to function declaration to modify the function with that functionality
    // If a function has a modifier passed to it, it will first look into the modifier code and execute it
    // Only after the modifier code has been executed, will the function continue with the rest of the code
    modifier onlyOwner {
        // require(msg.sender == owner);
        // This way with if statement and custom error is more gas efficient
        if (msg.sender != i_owner) revert NotOwner();
        // Underscore represents executing code of the function that is passed the modifier call
        _;
    }

    function withdraw() public {
        // for(/* starting index, ending index, step amount */)
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        // reset the array
        funders = new address[](0);
        // withdraw the funds
        // // transfer => max 2300 gas and throws error if it fails
        // this keyword refers to the contract
        // to send tokens we need to typecast the address as payable
        // payable(msg.sender).transfer(address(this).balance);
        // // send => max 2300 gas and returns boolean if it fails
        // store the result in a boolean value, so that if the transaction fails, we will be able to revert the transaction with the require statement
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");
        // call => forwards all gas and returns boolean if it fails
        // call is usually recommended to use for sending tokens
        // Get callSuccess variable, which we use in the require statement to revert the transaction if necessary
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");

    }

    // What happens if people send this contract ETH without calling the fund function?
    // We can catch such events with fallback and recieve functions

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

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }
}