// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

//@author Gwendal Saloum
//@mon template (de gwendal)

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC20.sol";

interface FinalToken {
    function name() public view returns (string);
    function symbol() public view returns (string);
    function decimals() public view returns (uint8);
    function totalSupply() public view returns (uint256);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
}

contract FinalToken is Ownable, ERC20, PaymentSplitter {

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

}