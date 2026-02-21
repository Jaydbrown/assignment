// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {saveEther} from "../src/saveEther.sol";

contract saveEtherScript is Script {
    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        new saveEther();
        vm.stopBroadcast();
    }
}