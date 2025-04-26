// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {VerifiedDocContracts} from "../src/VerifiedDocContracts.sol";

contract VerifiedDocContractsTest is Test {
    VerifiedDocContracts public verifiedDocs;
    address public owner;
    address public nonOwner;

    bytes32 public sampleHash1 = keccak256(abi.encodePacked("document1"));
    bytes32 public sampleHash2 = keccak256(abi.encodePacked("document2"));
    bytes32 public sampleHash3 = keccak256(abi.encodePacked("document3"));

    function setUp() public {
        owner = address(this);
        nonOwner = address(0x1);
        verifiedDocs = new VerifiedDocContracts();
    }

    function testOwnership() public {
        assertEq(verifiedDocs.owner(), owner);
    }

    function testRegisterHash() public {
        verifiedDocs.registerHash(sampleHash1);

        (bool verified, uint256 timestamp) = verifiedDocs.verifyHash(sampleHash1);
        assertTrue(verified);
        assertEq(timestamp, block.timestamp);
    }

    function testRegisterHashFailsWhenAlreadyRegistered() public {
        verifiedDocs.registerHash(sampleHash1);
        
        vm.expectRevert(VerifiedDocContracts.HashAlreadyRegistered.selector);
        verifiedDocs.registerHash(sampleHash1);
    }

    function testOnlyOwnerCanRegisterHash() public {
        vm.prank(nonOwner);
        vm.expectRevert(VerifiedDocContracts.NotOwner.selector);
        verifiedDocs.registerHash(sampleHash1);
    }

    function testVerifyHashFailsWhenNotRegistered() public {
        vm.expectRevert(VerifiedDocContracts.HashNotFound.selector);
        verifiedDocs.verifyHash(sampleHash1);
    }

    function testRegisterHashBatch() public {
        bytes32[] memory hashes = new bytes32[](3);
        hashes[0] = sampleHash1;
        hashes[1] = sampleHash2;
        hashes[2] = sampleHash3;

        verifiedDocs.registerHashBatch(hashes);

        // Verify each hash individually
        (bool verified1, uint256 timestamp1) = verifiedDocs.verifyHash(sampleHash1);
        assertTrue(verified1);
        assertEq(timestamp1, block.timestamp);

        (bool verified2, uint256 timestamp2) = verifiedDocs.verifyHash(sampleHash2);
        assertTrue(verified2);
        assertEq(timestamp2, block.timestamp);

        (bool verified3, uint256 timestamp3) = verifiedDocs.verifyHash(sampleHash3);
        assertTrue(verified3);
        assertEq(timestamp3, block.timestamp);
    }

    function testOnlyOwnerCanRegisterHashBatch() public {
        bytes32[] memory hashes = new bytes32[](2);
        hashes[0] = sampleHash1;
        hashes[1] = sampleHash2;

        vm.prank(nonOwner);
        vm.expectRevert(VerifiedDocContracts.NotOwner.selector);
        verifiedDocs.registerHashBatch(hashes);
    }

    function testRegisterHashBatchSkipsExistingHashes() public {
        // First register one hash individually
        verifiedDocs.registerHash(sampleHash1);
        uint256 originalTimestamp;
        {
            (bool verified, uint256 timestamp) = verifiedDocs.verifyHash(sampleHash1);
            assertTrue(verified);
            originalTimestamp = timestamp;
        }

        // Wait 1 block to ensure timestamp would be different
        vm.warp(block.timestamp + 1);
        
        // Then register in batch including the already registered hash
        bytes32[] memory hashes = new bytes32[](3);
        hashes[0] = sampleHash1; // already registered
        hashes[1] = sampleHash2; // new
        hashes[2] = sampleHash3; // new
        
        verifiedDocs.registerHashBatch(hashes);
        
        // Check that first hash still has original timestamp
        (bool verified1, uint256 timestamp1) = verifiedDocs.verifyHash(sampleHash1);
        assertTrue(verified1);
        assertEq(timestamp1, originalTimestamp); // Should keep original timestamp
        
        // Check that other hashes were registered with new timestamp
        (bool verified2, uint256 timestamp2) = verifiedDocs.verifyHash(sampleHash2);
        assertTrue(verified2);
        assertEq(timestamp2, block.timestamp); // Should have new timestamp
    }

    function testVerifyHashBatch() public {
        // Register some hashes
        bytes32[] memory registeredHashes = new bytes32[](2);
        registeredHashes[0] = sampleHash1;
        registeredHashes[1] = sampleHash2;
        verifiedDocs.registerHashBatch(registeredHashes);
        
        // Create verification array with registered and unregistered hashes
        bytes32[] memory hashesToVerify = new bytes32[](3);
        hashesToVerify[0] = sampleHash1; // registered
        hashesToVerify[1] = sampleHash2; // registered
        hashesToVerify[2] = sampleHash3; // not registered
        
        (bool[] memory verified, uint256[] memory timestamps) = verifiedDocs.verifyHashBatch(hashesToVerify);
        
        // Check results
        assertTrue(verified[0]);
        assertTrue(verified[1]);
        assertFalse(verified[2]);
        
        assertEq(timestamps[0], block.timestamp);
        assertEq(timestamps[1], block.timestamp);
        assertEq(timestamps[2], 0); // Unregistered hash should have timestamp 0
    }
}
