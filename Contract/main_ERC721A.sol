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
    mapping(address => bool) public is_admin;
    address public enxTokenAddress;
    uint256 public dailyPayment;


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

    function burn(uint _tokenId) external {
        require(_isApprovedOrOwner(msg.sender, _tokenId), "ERC721: transfer caller is not owner nor approved");
        _burn(_tokenId);
    }

    function burnByAdmin(uint _tokenId) external {
    require(isAdmin[msg.sender], "Only admins can burn NFTs");
    _burn(_tokenId);
} 

    function setAdmin(address _address, bool _status) external onlyOwner {
        isAdmin[_address] = _status;
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

    // Pour confier son NFT
    function confierNFT(uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "You don't own this NFT");
        _transfer(msg.sender, address(this), tokenId);
    }

    // Pour récupérer son NFT
    function recupNFT(uint256 tokenId) public {
        require(ownerOf(tokenId) == address(this), "This NFT is not entrusted to the contract");
        _transfer(address(this), msg.sender, tokenId);
    }

    function payDaily() public {
        uint256 balance = IERC20(enxTokenAddress).balanceOf(msg.sender);
        require(balance >= dailyPayment, "Insufficient ENX balance");
        require(IERC20(enxTokenAddress).transferFrom(msg.sender, address(this), dailyPayment), "Transfer failed");
        // Ajouter l'adresse de l'utilisateur à la liste des paiements publics
    }


    function checkBalanceAndBurn(uint256 tokenId) public {
        uint256 balance = IERC20(enxTokenAddress).balanceOf(msg.sender);
        if (balance < dailyPayment && ownerOf(tokenId) == address(this)) {
            _burn(tokenId);
        }
    }

}


