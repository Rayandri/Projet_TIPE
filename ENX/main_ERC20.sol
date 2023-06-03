// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ENXToken is ERC20, Ownable { // ERC20 est un standard de token sur la blockchain 
    constructor(uint256 initialSupply) ERC20("EnergyX", "ENX") {
        _mint(msg.sender, initialSupply);
    }

    function decimals() public view virtual override returns (uint8) { // permet de definir le nombre de decimal du token
        return 2;
    }

    function privateMint(address to, uint256 amount) external onlyOwner { 
        _mint(to, amount);
    }

    function publicBurn(address from, uint256 amount) public { // permet de detruire des tokens
        _burn(from, amount);
    }

    function balance() public view returns (uint256) { // permet de voir le solde de l'adresse qui appelle la fonction
        return balanceOf(msg.sender);
    }

    function checkBalance(address _address) public view returns (uint256) { // permet de voir le solde d'une adresse
        return balanceOf(_address);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) { // permet de transferer des tokens
        require(balanceOf(msg.sender) >= amount, "ERC20: transfer amount exceeds balance");
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function bathTransfer(address[] memory recipients, uint256[] memory amounts) public { // permet de transferer des tokens a plusieurs adresses
        require(recipients.length == amounts.length, "ERC20: recipients and amounts length mismatch");
        require(balanceOf(msg.sender) >= amounts[0], "ERC20: transfer amount exceeds balance");
        for (uint256 i = 0; i < recipients.length; i++) {
            transfer(recipients[i], amounts[i]);
        }
    }

}