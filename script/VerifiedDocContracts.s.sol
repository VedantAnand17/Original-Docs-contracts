// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {VerifiedDocContracts} from "../src/VerifiedDocContracts.sol";

contract CounterScript is Script {
    VerifiedDocContracts public verifiedDocContracts;

    function run() public {
        vm.startBroadcast();

        verifiedDocContracts = new VerifiedDocContracts();

        vm.stopBroadcast();
    }
}
