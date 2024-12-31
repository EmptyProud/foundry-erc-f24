// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Script} from "forge-std/Script.sol";
import {ManualToken} from "src/ManualToken.sol";

contract DeployManualToken is Script {
    uint256 public constant INITIAL_SUPPLY = 1000 ether;

    function run() external returns (ManualToken) {
        vm.startBroadcast();
        ManualToken manualToken = new ManualToken();
        vm.stopBroadcast();
        return manualToken;
    }
}
