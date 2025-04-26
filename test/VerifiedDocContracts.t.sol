// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/VerifiedDocContracts.sol";

contract VerifiedDocContractsTest is Test {
    VerifiedDocContracts private contractInstance;
    address private owner;
    address private addr1;
    address private addr2;
    bytes32 private docHash;

    function setUp() public {
        owner = address(this);
        addr1 = address(0x123);
        addr2 = address(0x456);

        contractInstance = new VerifiedDocContracts();
        docHash = keccak256(abi.encodePacked("sample-doc-hash"));
    }

    function testOwnerIsSetCorrectly() public view {
        assertEq(contractInstance.owner(), owner);
    }

    function testRegisterHashByOwner() public {
        contractInstance.registerHash(docHash);
        (bool verified, uint256 timestamp) = contractInstance.verifyHash(docHash);
        assertTrue(verified);
        assertEq(timestamp, block.timestamp);
    }

    function testRegisterHashRevertsIfAlreadyRegistered() public {
        contractInstance.registerHash(docHash);
        vm.expectRevert(VerifiedDocContracts.HashAlreadyRegistered.selector);
        contractInstance.registerHash(docHash);
    }

    function testVerifyHashByNonOwner() public {
        vm.startPrank(addr1);
        vm.expectRevert(VerifiedDocContracts.NotOwner.selector);
        contractInstance.registerHash(docHash);
        vm.stopPrank();
    }

    function testVerifyHash() public {
        contractInstance.registerHash(docHash);
        (bool verified, uint256 timestamp) = contractInstance.verifyHash(docHash);
        assertTrue(verified);
        assertEq(timestamp, block.timestamp);
    }

    function testVerifyHashNotFound() public {
        vm.expectRevert(VerifiedDocContracts.HashNotFound.selector);
        contractInstance.verifyHash(docHash);
    }
}
