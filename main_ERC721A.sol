// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

//@author Rayan Drissi
//@Contract d'energy 

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC721A.sol";



contract NFTERC721A is Ownable, ERC721A {

    using Strings for uint;

    mapping(address => uint) public amountNFTsPerWallet;

    enum Etape {
        Alpha,
        Beta,
        Public,
        Maintenance,
        End
    }

    string public baseURI;
    Etape public Etape_en_cours;
    uint public SalePrice = 1 ether;

    constructor(string memory _baseURI) ERC721A("Contract Energy", "AGR-DET")
     {
        baseURI = _baseURI;
    }

    modifier callerIsUser() {
        require(tx.origin == msg.sender, "The caller is another contract");
        _;
    }

    function Mint(address _account, uint _quantity) external payable callerIsUser {
        uint price = SalePrice;
        require(price != 0, "le prix est gratuit");
        require( Etape_en_cours == Etape.Public, "La vente n'a pas commencer");
        require(msg.value >= price * _quantity, "Not enought funds");
        require(amountNFTsPerWallet[msg.sender] == 0, "Vous avez deja un contract");
        _safeMint(_account, _quantity);
    }

    function setBaseUri(string memory _baseURI) external onlyOwner {
        baseURI = _baseURI;
    }

    function currentTime() internal view returns(uint) {
        return block.timestamp;
    }

    function setStep(uint _step) external onlyOwner {
        Etape_en_cours = Etape(_step);
    }

    // le URI permet de relier a une image et les MetaData
    function tokenURI(uint _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId), "URI query for nonexistent token");

        return string(abi.encodePacked(baseURI, _tokenId.toString(), ".json"));
    }

    // Pour RUG le projet 
    function transferAllFunds(address payable receveur) external onlyOwner {
        uint balance = address(this).balance;
        receveur.transfer(balance);
    }



  
}


