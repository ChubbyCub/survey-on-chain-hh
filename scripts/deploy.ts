// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  console.log("Account balance:", (await deployer.getBalance()).toString());
  const depth = 20;
  const externalNullifier = 1121212;
  // 0xE09B4d15a1BADB4c019a179478128F9fe74ef454  T3
  // 0x20B79274b2B25AdD5bF356B5daE59ce0442ce0b1  T6
  // 0xdEC940115B1Ae966D18B2a08782427fd152Db28A  Semaphore
  // 0x5FbDB2315678afecb367f032d93F642f64180aa3  Utils
  // 0x5FbDB2315678afecb367f032d93F642f64180aa3  Platform
  const Semaphore = await ethers.getContractFactory("Platform",{
    libraries: {
      Utils: "0x5FbDB2315678afecb367f032d93F642f64180aa3",
    },
  });
  const semaphore = await Semaphore.deploy();

  console.log("Semaphore address:", semaphore.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
