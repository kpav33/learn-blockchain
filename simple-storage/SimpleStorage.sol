// SPDX-License-Identifier: MIT
pragma solidity 0.8.8; // Exact version of solidity to use declared
// >=0.8.7 <0.9.0 => any version including 0.8.7 up to 0.9.0 is ok
// ^0.8.7 the caret ^ symbol means that any version above the specified version is ok for this contract

// EVM, Ethereum Virtual Machine => Standard how to deploy smart contracts to Ethereum
// Any blockchain that implements type of EVM, you can deploy Solidity code to (Avalance, Fantom, Polygon)

contract SimpleStorage {
    // Types: boolean, uint (positive number), int (positive or negative number), address, bytes, strings
    // bool hasFavoriteNumber = true;
    // uint256 favoriteNumber = 123; // Automatically defaults to 256, max number size in this case is 256 bits, lowest value is 8, we can go up in steps of 8
    // int256 favoriteInt = -123; // Usually you want to be explicit and you should declare the bit value
    // string favoriteNumberInText = "Five";
    // address myAddress = 0xd953fe310425fd4dBe07B722A840756a707081A6;
    // bytes32 favoriteBytes = "cat"; // Representing how many bytes the object should be, strings are bytes objects, but only for text, max size is 32

    // If you don't declare anything the default value of null in Solidity is 0
    // Functions and variables have four possible visibility specifiers: public, private, external, internal
    // Public is visibile internally and externally (creates a getter function for variables, which is implicitly assigned to public variables)
    // Private means only visible in the current contract
    // External means its only visible externally, outside of the current contract
    // Internal means only the current contract and its children can read it

    uint256 public favoriteNumber; // Without specified visibility, the default value for variables is internal and its getter function is a view function

    // A mapping is a data structure where a key is "mapped" to a single value (dictionary)
    // string name will map to a specific number
    mapping(string => uint256) public nameToFavoriteNumber;

    // Create a new value based on the People struct
    // People public person = People({ favoriteNumber: 2, name: "Patrick" });

    // With struct we created a new type, kind of like a uint256 or string, which we can use
    struct People {
        uint256 favoriteNumber;
        string name;
    }

    // Array stores a list or a sequence of objects
    // uint256 public favoriteNumbersList;
    // Dynamic arrays don't have the size given at its initialization
    // People[3] public people => Max array size is 3 values, this is a fixed size array
    People[] public people;

    // Calldata, memory, storage
    // Calldata and memory mean that data will only exist temporarily => For example during the function execution
    // Storage data will exists even outside of function executions, by default variable are stored in storage
    // Calldata is temporary variables that can't be modified, memory is temporary that can be modified, storage is permanent that can be modified
    // Data location can only be specified for an array, struct or mapping types, rest get location automatically assigned
    function addPerson(string memory _name, uint256 _favoriteNumber) public {
        // Arrays have push method on them, which allows us to add values to them
        // People memory newPerson = People({ favoriteNumber: _favoriteNumber, name: _name }); people.push(newPerson); => Alternative way to add a value to an array
        people.push(People(_favoriteNumber, _name));
        // Store the favorite number into the mapping under the name string
        nameToFavoriteNumber[_name] = _favoriteNumber;
    }


    // Prefixing the parameter with underscore is to different it with the favoriteNumber variable
    function store(uint256 _favoriteNumber) public {
        favoriteNumber = _favoriteNumber;
        // uint256 testVar = 5;
        // This would cost some gas, because it is called inside of a function that costs gas
        // retrieve();
    }

    // function something() public {
    //     // Can't do this, because testVar is outside of the scope of the something function
    //     // Variables can only be viewed in the scope where they are
    //     testVar = 6;
    // }

    // view and pure functions, when called alone, don't spend gas
    // view and pure functions disallow modification of state
    // pure functions also disallow reading from the state and you only spend gas if you modify blockchain state
    // returns() specifies what the function will give us, when we call it
    function retrieve() public view returns(uint256) {
        return favoriteNumber;
    }

    // Pure function example
    // If a gas calling function calls a view or pure function - only then will it cost gas
    // function add() public pure returns(uint256) {
    //     return (1 + 1);
    // }
}

// 0xd9145CCE52D386f254917e481eB44e9943F39138 Address of the deployed contract

// Recap
// First declare Solidity version and license
// Then you can create your contract object and name it (similar to class)
// Types unsigned int, boolean, string, bytes...
// If you want to create a new type you can create a struct
// You can create arrays and dictionaries (mappings)
// You can create functions that modify or don't modify the state of the blockchain
// View and pure functions don't modify state
// You can also specify different data locations => calldata, memory, storage
// When you compile the code, it gets compiled down to the EVM specifications