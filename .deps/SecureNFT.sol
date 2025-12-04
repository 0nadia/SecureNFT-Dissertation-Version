// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// NFT standard with metadata
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
// access control (roles)
import "@openzeppelin/contracts/access/AccessControl.sol";
// reentrancy protection
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
// pause/unpause contract
import "@openzeppelin/contracts/security/Pausable.sol";

// contract with security features and access control
contract SecureNFT is ERC721URIStorage, AccessControl, ReentrancyGuard, Pausable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE"); // secure hashed role
    uint256 private tokenIdCounter; // token ID tracker
    uint256 public constant MAX_SUPPLY = 5; // hard cap on NFTs

    mapping(uint256 => bool) public metadataFrozen; // tracks which NFTs are frozen
    mapping(string => bool) private usedURIs; // tracks used metadata URIs

    // custom event logs
    event TokenMinted(address to, uint256 tokenId, string uri);
    event TokenBurned(uint256 tokenId);
    event MetadataFrozen(uint256 tokenId);
    event ContractPaused(address admin);
    event ContractUnpaused(address admin);

    constructor() ERC721("SecureNFT", "SNFT") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender); // deployer is admin
        _grantRole(MINTER_ROLE, msg.sender); // deployer is allowed to mint
    }

    // mint NFTs (only minter, only if not paused, and metadata not frozen)
    function mint(address to, string memory uri)
        public
        onlyRole(MINTER_ROLE)
        whenNotPaused
        nonReentrant
    {
        require(tokenIdCounter < MAX_SUPPLY, "Max supply reached"); // check if supply cap is reached
        require(!metadataFrozen[tokenIdCounter], "Metadata is frozen"); // prevent minting if metadata is locked
        require(!usedURIs[uri], "Metadata already used"); // prevent duplicate metadata

        uint256 tokenId = tokenIdCounter;
        _safeMint(to, tokenId); // mint token safely
        _setTokenURI(tokenId, uri); // set metadata link
        usedURIs[uri] = true; // mark URI as used
        emit TokenMinted(to, tokenId, uri); // log mint
        tokenIdCounter++; // increment counter
    }

    // freeze metadata for a token 
    function freezeMetadata(uint256 tokenId) public onlyRole(MINTER_ROLE) {
        require(_existsPublic(tokenId), "Token does not exist"); // safe check
        metadataFrozen[tokenId] = true; // lock metadata
        emit MetadataFrozen(tokenId); // log freeze
    }

    // burn an NFT 
    function burn(uint256 tokenId) public {
        address owner = ownerOf(tokenId); // get current owner
        require(
            msg.sender == owner || // must be owner
            getApproved(tokenId) == msg.sender || // or approved for this token
            isApprovedForAll(owner, msg.sender), // or approved for all tokens
            "Not owner or approved"
        );
        _burn(tokenId); // destroy token
        emit TokenBurned(tokenId); // log burn
    }

    // emergency stop functions (pause/unpause contract)
    function pause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause(); // stop minting
        emit ContractPaused(msg.sender); // log pause
    }

    function unpause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause(); // resume minting
        emit ContractUnpaused(msg.sender); // log unpause
    }

    // check if a token exists 
    function _existsPublic(uint256 tokenId) internal view returns (bool) {
        try this.ownerOf(tokenId) returns (address) {
            return true;
        } catch {
            return false;
        }
    }

// testing functions for metadata freezing
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal override {
        require(!metadataFrozen[tokenId], "Metadata is frozen");
        super._setTokenURI(tokenId, _tokenURI);
    }

    function updateTokenURI(uint256 tokenId, string memory newURI) public onlyRole(MINTER_ROLE) {
    require(_existsPublic(tokenId), "Token does not exist");
    _setTokenURI(tokenId, newURI);
}


    // support multiple inherited interfaces
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(AccessControl, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
