pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";

contract ENXToken is ERC20, ERC20Detailed {
    constructor(uint256 initialSupply) ERC20Detailed("EnergyX", "ENX", 2) public {
        _mint(msg.sender, initialSupply);
    }


}