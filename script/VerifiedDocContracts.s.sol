// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {VerifiedDocContracts} from "../src/VerifiedDocContracts.sol";

contract DeployVerifiedDocContracts is Script {
    function run() external {
        // Start broadcasting transactions
        vm.startBroadcast();

        // Deploy the contract
        VerifiedDocContracts verifiedDocs = new VerifiedDocContracts();
        
        // Stop broadcasting transactions
        vm.stopBroadcast();

        // Output the deployed contract address
        console.log("VerifiedDocContracts deployed at:", address(verifiedDocs));
    }
}
