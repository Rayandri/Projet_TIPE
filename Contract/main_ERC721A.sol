// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

//@author Rayan Drissi
//@Contract d'energy 

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC721A.sol";
import "./IERC721A.sol";



contract NFTERC721A is Ownable, ERC721A {

    using Strings for uint;

    mapping(address => uint) public amountNFTsPerWallet;
    mapping(address => bool) public is_admin;
    address public enxTokenAddress;
    uint public dailyPayment;

    struct Confier {
        address personne;
        uint idNFT;
        bool is_confier;
        uint dette;
    }
    
    Confier[] public nftconfier;

    enum Etape {
        Alpha,
        Beta,
        Public,
        Maintenance,
        End
    }

    string public baseURI;
    Etape public Etape_en_cours;
    uint public SalePrice = 0.001 ether;

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
    require(is_admin[msg.sender], "Only admins can burn NFTs");
    _burn(_tokenId);
} 

    function setAdmin(address _address, bool _status) external onlyOwner {
        is_admin[_address] = _status;
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
        transferFrom(msg.sender, address(this), tokenId);

        nftconfier.push(Confier({
            personne: msg.sender, 
            idNFT: tokenId,
            is_confier: true
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
                    break;
                }
            }
            _burn(tokenId);
        }
    }

    function pay(uint _amount) public {
        
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


