// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import another contract into this contract
import "./SimpleStorage.sol";

contract StorageFactory {

    // Create a global variable of the SimpleStorage type
    // SimpleStorage public simpleStorage;
    // Create an array stored addresses of the deployed SimpleStorage contracts
    SimpleStorage[] public simpleStorageArray;

    function createSimpleStorageContract() public {
        // By using the "new" keyword, Solidity knows we want to deploy a new contract
        // simpleStorage = new SimpleStorage();
        // Create a variable that will store the newly created contract's address and push it into the array
        SimpleStorage simpleStorage = new SimpleStorage();
        simpleStorageArray.push(simpleStorage);
    }

    function sfStore(uint256 _simpleStorageIndex, uint256 _simpleStorageNumber) public {
        // To interact with any contract, you will always need its Address and ABI (Application Binary Interface - Tells the code how to interact with contract)
        // The address we are storing in the array - It is what is returned to the variable when you use the "new" keyword to create a new contract
        // We automatically get the ABI when we import a contract
        // Get the desired SimpleStorage object from the simpleStorageArray
        // SimpleStorage simpleStorage = simpleStorageArray[_simpleStorageIndex];
        // Call the store function defined in the SimpleStorage contract
        // simpleStorage.store(_simpleStorageNumber);
        // Simplified
        simpleStorageArray[_simpleStorageIndex].store(_simpleStorageNumber);
    }

    function sfGet(uint256 _simpleStorageIndex) public view returns(uint256) {
        // SimpleStorage simpleStorage = simpleStorageArray[_simpleStorageIndex];
        // Call the retrieve function defined in the SimpleStorage contract
        // return simpleStorage.retrieve();
        // Simplified
        return simpleStorageArray[_simpleStorageIndex].retrieve();
    }
}