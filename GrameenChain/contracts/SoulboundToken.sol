// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract SoulboundToken is ERC721URIStorage, Ownable {
    uint256 public tokenIdCounter;

    // Simple reputation tracking
    mapping(address => uint256) public repayments;
    mapping(address => uint256) public defaults;

    constructor(address initialOwner) ERC721("GrameenSoulbound", "GSBT") Ownable() {
        transferOwnership(initialOwner);
    }

    function mint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = tokenIdCounter;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        tokenIdCounter++;
    }

    // Called by Escrow contract after successful repayment
    function recordRepayment(uint /*loanId*/) external onlyOwner {
        repayments[tx.origin] += 1;
    }

    // Called by Escrow contract when user defaults
    function recordDefault(uint /*loanId*/) external onlyOwner {
        defaults[tx.origin] += 1;
    }

    // Non-transferable overrides
    function transferFrom(address, address, uint256) public pure override(ERC721, IERC721) {
        revert("Soulbound: non-transferable");
    }

    function safeTransferFrom(address, address, uint256) public pure override(ERC721, IERC721) {
        revert("Soulbound: non-transferable");
    }

    function safeTransferFrom(address, address, uint256, bytes memory) public pure override(ERC721, IERC721) {
        revert("Soulbound: non-transferable");
    }

    function approve(address, uint256) public pure override(ERC721, IERC721) {
        revert("Soulbound: approval disabled");
    }

    function setApprovalForAll(address, bool) public pure override(ERC721, IERC721) {
        revert("Soulbound: approval disabled");
    }

    function getApproved(uint256) public pure override(ERC721, IERC721) returns (address) {
        return address(0);
    }

    function isApprovedForAll(address, address) public pure override(ERC721, IERC721) returns (bool) {
        return false;
    }
}
