// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "solmate/tokens/ERC20.sol";

contract Maxi is ERC20("Maxi", "MAX", 18) {
    constructor(address user) {
        _mint(user, 100000e18);
    }
}
