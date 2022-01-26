// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./semaphore/Semaphore.sol";
import "hardhat/console.sol";

contract SemaphoreDeployer {
    address semaphoreAddress;
    
    function deploySemaphore() public {
        console.log("Creating Semaphore");
        semaphoreAddress = address(new Semaphore(20, 1111));
        console.log(semaphoreAddress);
    }

    function getSemaphoreAddress() public view returns (address) {
        return semaphoreAddress;
    }
}