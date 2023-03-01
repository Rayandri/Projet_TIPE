// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./ERC20.sol";

contract ENXToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("EnergyX", "ENX") {
        _mint(msg.sender, initialSupply);
    }

    function decimals() public view virtual override returns (uint8) { // override default decimals
        return 2;
    }


}