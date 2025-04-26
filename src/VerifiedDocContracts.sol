// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract VerifiedDocContracts {
    address public immutable owner;

    struct Doc {
        bool verified;
        uint256 timestamp;
    }

    mapping(bytes32 => Doc) private pdfHashes;

    event HashRegistered(address indexed registrar, bytes32 indexed hash, uint256 timestamp);

    error NotOwner();
    error HashAlreadyRegistered();
    error HashNotFound();

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    function registerHash(bytes32 _hash) external onlyOwner {
        if (pdfHashes[_hash].verified) revert HashAlreadyRegistered();

        pdfHashes[_hash] = Doc({verified: true, timestamp: block.timestamp});
        emit HashRegistered(msg.sender, _hash, block.timestamp);
    }

    function registerHashBatch(bytes32[] calldata _hashes) external onlyOwner {
        uint256 batchLength = _hashes.length;
        for (uint256 i = 0; i < batchLength; i++) {
            bytes32 hash = _hashes[i];
            
            if (!pdfHashes[hash].verified) {
                pdfHashes[hash] = Doc({verified: true, timestamp: block.timestamp});
                emit HashRegistered(msg.sender, hash, block.timestamp);
            }
        }
    }

    function verifyHash(bytes32 _docHash) external view returns (bool, uint256) {
        Doc storage pdf = pdfHashes[_docHash];
        if (!pdf.verified) revert HashNotFound();
        return (pdf.verified, pdf.timestamp);
    }
    
    function verifyHashBatch(bytes32[] calldata _docHashes) external view returns (bool[] memory verified, uint256[] memory timestamps) {
        uint256 batchLength = _docHashes.length;
        verified = new bool[](batchLength);
        timestamps = new uint256[](batchLength);
        
        for (uint256 i = 0; i < batchLength; i++) {
            Doc storage pdf = pdfHashes[_docHashes[i]];
            verified[i] = pdf.verified;
            timestamps[i] = pdf.timestamp;
        }
        
        return (verified, timestamps);
    }
}
