// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SimpleStorage.sol";

// ExtraStorage is exactly the same as SimpleStorage by inheriting all of its functionalities
contract ExtraStorage is SimpleStorage {
    // override the inherited functions with keywords virtual and override
    function store(uint256 _favoriteNumber) public override {
        favoriteNumber = _favoriteNumber + 5;
    }
}