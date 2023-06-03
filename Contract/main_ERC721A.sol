// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

//@author Rayan Drissi
//@Contract d'energy 

/* 
to do a la compitation:
    -set up the baseURI pour avoir les images des NFTs
    -set up the enxTokenAddress 
    -set up the dailyPayment pour savoir combien de ENX par jour
    -set up the SalePrice (de base 0.001 ether)


*/

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC721A.sol";
import "./IERC721A.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract NFTERC721A is Ownable, ERC721A {

    using Strings for uint;

    // un mapping est l'equivalent d'un dictionaire
    mapping(address => uint) public amountNFTsPerWallet; 
    mapping(address => bool) public is_admin; // Permet de stocker la liste des admins
    
    address public enxTokenAddress; // L'adresse du contract ENX sur la blockchain pour pouvoir interagir avec 
    uint public dailyPayment; // Le montant de ENX a payer par jour (peut changer en temps reel)

    struct Confier { // cette struct permet de stocker les informations des contrat 
        address personne; //lorsque l'on active (lorsque qu'on recoit de l'electricité et qu'on paye )
        uint idNFT;
        bool is_confier;
        uint dette;
    }
    
    Confier[] public nftconfier; //declaration de la variable nftconfier

    enum Etape { // enum permet de definir des etapes pratique pour mettre en pause le contract en cas de probleme
        Public,
        Maintenance
    }

    string public baseURI;
    Etape public Etape_en_cours = Etape.Public;
    uint public SalePrice = 0.001 ether;

    constructor(string memory _baseURI) ERC721A("Contract Energy", "AGR-DET"){ //l'equivalent d'un __init__() en python
        baseURI = _baseURI;
    }

    modifier callerIsUser() { // permet de verifier que l'appelant est un utilisateur et non un programme
        require(tx.origin == msg.sender, "The caller is another contract");
        _;
    }

    function Mint(address _account, uint _quantity) external payable callerIsUser { // permet de creer un NFT
        uint price = SalePrice;
        require(price != 0, "le prix est gratuit");
        require( Etape_en_cours == Etape.Public, "La vente n'a pas commencer");
        if (msg.sender != owner()) {
            require(msg.value >= price * _quantity, "Not enought funds");
            require(amountNFTsPerWallet[msg.sender] == 0, "Vous avez deja un contract");
        }
        
        _safeMint(_account, _quantity);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) { 
        // permet de verifier que l'appelant est le proprietaire du NFT
        address owner = ERC721A.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    function burn(uint _tokenId) external {
        // permet de bruler un NFT
        require(_isApprovedOrOwner(msg.sender, _tokenId), "ERC721: transfer caller is not owner nor approved");
        _burn(_tokenId);
    }

    function burnByAdmin(uint _tokenId) external {
        // permet de bruler un NFT par un admin
    require(is_admin[msg.sender], "Only admins can burn NFTs");
    _burn(_tokenId);
} 

    function setAdmin(address _address, bool _status) external onlyOwner { // permet de definir un admin
        is_admin[_address] = _status;
    }

    function setEnxTokenAddress(address _address) external onlyOwner { // permet de definir l'adresse du contract ENX
        enxTokenAddress = _address;
    }

    function setDailyPayment(uint _amount) external onlyOwner { // permet de definir le montant de ENX a payer par jour
        dailyPayment = _amount;
    }

    function setSalePrice(uint _price) external onlyOwner { // permet de definir le prix de vente
        SalePrice = _price;
    }


    function setBaseUri(string memory _baseURI) external onlyOwner { // permet de definir le baseURI
        baseURI = _baseURI;
    }

    function currentTime() internal view returns(uint) { // permet de recuperer le temps actuel
        return block.timestamp;
    }

    function setStep(uint _step) external onlyOwner { // permet de definir l'etape en cours
        Etape_en_cours = Etape(_step);
    }

    // le URI permet de relier a une image et les MetaData
    function tokenURI(uint _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId), "URI query for nonexistent token");
        return string(abi.encodePacked(baseURI, _tokenId.toString(), ".json"));
    }

    function transferAllFunds(address payable receveur) external onlyOwner {
        // permet de transferer tout les fonds du contract vers une adresse
        uint balance = address(this).balance;
        receveur.transfer(balance);
    }

    // Pour confier son NFT
    function confierNFT(uint256 tokenId) public { // permet de verouiller son nft dans le compteur 
        require(ownerOf(tokenId) == msg.sender, "You don't own this NFT");
        transferFrom(msg.sender, address(this), tokenId);

        nftconfier.push(Confier({
            personne: msg.sender, 
            idNFT: tokenId,
            is_confier: true,
            dette: 0
        }));
    }

    

    function isConfier_token(uint256 tokenId) public view returns (bool) {
        for (uint i = 0; i < nftconfier.length; i++) {
            if (nftconfier[i].idNFT == tokenId) {
                return nftconfier[i].is_confier;
            }
        }
        return false;
    }

    function isConfier_adress(address _address) public view returns (bool) {
        for (uint i = 0; i < nftconfier.length; i++) {
            if (nftconfier[i].personne == _address) {
                return nftconfier[i].is_confier;
            }
        }
        return false;
    }

    function recupIndex(address _address) public view returns (uint) {
        for (uint i = 0; i < nftconfier.length; i++) {
            if (nftconfier[i].personne == _address) {
                return i;
            }
        }
    }

    // Pour récupérer son NFT
    function recupNFT(address _address) public {
        require(isConfier_adress(_address), "You don't have NFT entrusted to the contract");
        for (uint i = 0; i < nftconfier.length; i++) {
            if (nftconfier[i].personne == _address) {
                transferFrom(address(this), _address, nftconfier[i].idNFT);
                nftconfier[i].is_confier = false;
                break;
            }
        }
    }


    function payDaily() public {
        uint256 balance = IERC20(enxTokenAddress).balanceOf(msg.sender);
        require(balance >= dailyPayment, "Insufficient ENX balance");
        require(IERC20(enxTokenAddress).transferFrom(msg.sender, address(this), dailyPayment), "Transfer failed");
        // Ajouter l'adresse de l'utilisateur à la liste des paiements publics
    }

    

    function checkBalanceAndBurn(uint tokenId) public {
        uint balance = IERC20(enxTokenAddress).balanceOf(msg.sender);
        if (balance < dailyPayment && ownerOf(tokenId) == address(this)) {
            // Définir la struct correspondante sur "false"
            for (uint i = 0; i < nftconfier.length; i++) { 
                if (nftconfier[i].idNFT == tokenId) {
                    nftconfier[i].is_confier = false;
                    nftconfier[i].dette += dailyPayment;
                    break;
                }
            }
            if (nftconfier[i].dette > 2*dailyPayment) { // si la dette est superieur a 2 fois le dailyPayment alors on brule le NFT
                _burn(tokenId);
            }
            
        }
    }

    function pay(uint _amount) public { //fonction qui s'appellera automatiquement tout les jours
        
        uint balance = IERC20(enxTokenAddress).balanceOf(msg.sender);
        uint i = recupIndex(msg.sender);

        if (balance < _amount + nftconfier[i].dette) {
            
            // si il avais deja une dette
            if (nftconfier[i].dette > 0) {
                nftconfier[i].is_confier = false;
                nftconfier[i].dette = 0;
                _burn(nftconfier[i].idNFT);
            }
            // si il n'avais pas de dette
            else {
                nftconfier[i].dette = _amount;
            }
        }
        else {
            IERC20(enxTokenAddress).transferFrom(msg.sender, address(this), _amount + nftconfier[i].dette);
        }
    }

}


