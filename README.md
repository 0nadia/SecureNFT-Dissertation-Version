# SecureNFT - Dissertation Version
The original NFT smart contract I developed for my final year Computer Science dissertation: "Mitigating Security Risks in NFT Smart Contracts". It is a partial implementation to demonstrate common security issues and their mitigation strategies in NFT contracts.

## Overview:
- ERC-721 NFT contract built with OpenZeppelin
- Implements several security features 
- Used as the baseline for my research/ testing

## Features
- **ERC-721 standard:** Full NFT functionality with metadata support
- **Capped supply:** `MAX_SUPPLY = 5`
- **URI-based metadata:** Stores metadata URIs on-chain
- **Burn mechanism:** Tokens can be burned by owner/ approved address

## Security Features
- **Role based access control:** Separate admin/ minter roles using OpenZeppelin's `AccessControl`
- **Reentrancy Protection:** `ReentrancyGuard` used on minting
- **Pausable:** Emergency stop mechanism for admin
- **Metadata freezing:** Prevents updates to frozen tokens
- **URI Uniqueness:** Blocks duplicate metadata from being reused



