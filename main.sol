// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";

contract mainContract is Ownable {
    address public contractERC721A;
    address public contractERC20;

    constructor(address _contractERC721A, address _contractERC20) {
        contractERC721A = _contractERC721A;
        contractERC20 = _contractERC20;
    }

    function setContractERC721A(address _contractERC721A) external onlyOwner {
        contractERC721A = _contract721A;
    }

    function setContractERC20(address _contractERC20) external onlyOwner {
        contractERC20 = _contractERC20;
    }

    function getContractERC721A() external view returns (address) {
        return contractERC721A;
    }

    function getContractERC20() external view returns (address) {
        return contractERC20;
    }

    function withdrawENX(address _token, uint256 _amount) external onlyOwner {
        require(_amount > 0, "Amount must be greater than 0");
        if (_token == address(0)) {
            payable(msg.sender).transfer(_amount);
        } else {
            IERC20(_token).transfer(msg.sender, _amount);
        }
    }
}