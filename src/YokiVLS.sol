// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;

import { ERC721AQueryable } from "ERC721A/extensions/ERC721AQueryable.sol";
import "ERC721A/ERC721A.sol";
import { IERC2981, ERC2981 } from "openzeppelin/token/common/ERC2981.sol";
import "./IERC4906.sol";
import {AccessControl} from "openzeppelin/access/AccessControl.sol";

error MaxSupplyOver();
error NotEnoughFunds(uint256 balance);
error NotMintable();
error AlreadyClaimedMax();
error MintAmountOver();

contract YokiVLS is ERC721A, IERC4906, ERC721AQueryable, AccessControl, ERC2981 {
    string private constant BASE_EXTENSION = ".json";
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 public immutable maxSupply = 10000;
    bool public mintable = true;

    uint256 public publicCost = 0.002 ether;
    string private baseURI = "https://gateway.irys.xyz/Ni2eRGuXwx0I-m0nxHoaBO_LLDt5b39xeI9ngzaDiEg/";

    mapping(uint256 => string) private metadataURI;

    constructor() ERC721A("YokiVLS", "YokiVLS") {
        _setDefaultRoyalty(_msgSender(), 1000);
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    modifier whenMintable() {
        if (mintable == false) revert NotMintable();
        _;
    }

    // internal
    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function tokenURI(uint256 tokenId) public view virtual override(ERC721A, IERC721A) returns (string memory) {
        if (bytes(metadataURI[tokenId]).length == 0) {
            return string(abi.encodePacked(ERC721A.tokenURI(tokenId), BASE_EXTENSION));
        } else {
            return metadataURI[tokenId];
        }
    }

    function setTokenMetadataURI(uint256 tokenId, string memory metadata) external onlyRole(DEFAULT_ADMIN_ROLE) {
        metadataURI[tokenId] = metadata;
        emit MetadataUpdate(tokenId);
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function mint(address _to, uint256 _mintAmount) external payable whenMintable onlyRole(MINTER_ROLE) {
        if (_totalMinted() + _mintAmount > maxSupply) revert MaxSupplyOver();
        if (msg.value < publicCost * _mintAmount) revert NotEnoughFunds(msg.value);

        _mint(_to, _mintAmount);
    }

    function ownerMint(address _address, uint256 count) external onlyRole(MINTER_ROLE) {
        _safeMint(_address, count);
    }

    function setPublicCost(uint256 _publicCost) external onlyRole(DEFAULT_ADMIN_ROLE) {
        publicCost = _publicCost;
    }

    function setMintable(bool _state) external onlyRole(DEFAULT_ADMIN_ROLE) {
        mintable = _state;
    }

    function setBaseURI(string memory _newBaseURI) external onlyRole(DEFAULT_ADMIN_ROLE) {
        baseURI = _newBaseURI;
        emit BatchMetadataUpdate(_startTokenId(), totalSupply());
    }

    function withdraw() external virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        payable(_msgSender()).transfer(address(this).balance);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721A, IERC721A, ERC2981, AccessControl) returns (bool) {
        return ERC721A.supportsInterface(interfaceId) || ERC2981.supportsInterface(interfaceId) || AccessControl.supportsInterface(interfaceId);
    }

    function setDefaultRoyalty(address receiver, uint96 feeNumerator) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _setDefaultRoyalty(receiver, feeNumerator);
    }
}
