// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

//@author Rayan Drissi
//@mon template 

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./ERC721A.sol";

contract NFTERC721A is Ownable, ERC721A, PaymentSplitter {

    using Strings for uint;

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

    bytes32 public merkleRoot;

    uint public saleStartTime = 1646737200;

    mapping(address => uint) public amountNFTsperWalletWhitelistSale;

    uint private teamLength;

    constructor(address[] memory _team, uint[] memory _teamShares, bytes32 _merkleRoot, string memory _baseURI) ERC721A("Contract D'electricité", "AGR-DET")
    PaymentSplitter(_team, _teamShares) {
        merkleRoot = _merkleRoot;
        baseURI = _baseURI;
        teamLength = _team.length;
    }

    modifier callerIsUser() {
        require(tx.origin == msg.sender, "The caller is another contract");
        _;
    }


    function publicSaleMint(address _account, uint _quantity) external payable callerIsUser {
        uint price = SalePrice;
        require(price != 0, "le prix est gratuit");
        require( Etape_en_cours == Etape.Public, "La vente n'a pas commencer");
        require(msg.value >= price * _quantity, "Not enought funds");
        _safeMint(_account, _quantity);
    }

    

    function setSaleStartTime(uint _saleStartTime) external onlyOwner {
        saleStartTime = _saleStartTime;
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
    function transferAllFunds(address payable recipient) external onlyOwner {
        uint balance = address(this).balance;
        recipient.transfer(balance);
    }


    //ReleaseALL
    function releaseAll() external {
        for(uint i = 0 ; i < teamLength ; i++) {
            release(payable(payee(i)));
        }
    }


    receive() override external payable {
        revert('Only if you mint');
    }

}
