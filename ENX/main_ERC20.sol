// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ENXToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("EnergyX", "ENX") {
        _mint(msg.sender, initialSupply);
    }

    function decimals() public view virtual override returns (uint8) { // override default decimals
        return 2;
    }

    function mint(address to, uint256 amount) external OnlyOwner {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public {
        _burn(from, amount);
    }

}