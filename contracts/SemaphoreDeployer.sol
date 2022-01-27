// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./semaphore/Semaphore.sol";
import "hardhat/console.sol";

contract SemaphoreDeployer is Ownable {
    address semaphoreAddress;
    
    function deploySemaphore() public {
        console.log("Creating Semaphore");
        Semaphore sem = new Semaphore(20, 1111);
        sem.transferOwnership(msg.sender);
        console.log("SemaphoreDeployer: this is semaphore owner");
        console.log(msg.sender);
        semaphoreAddress = address(sem);
        console.log(semaphoreAddress);
    }

    function getSemaphoreAddress() public view returns (address) {
        return semaphoreAddress;
    }
}