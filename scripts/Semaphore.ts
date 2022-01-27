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
  // npx hardhat run scripts/Semaphore.ts --network localhost

  const PoseidonT3 = await ethers.getContractFactory("PoseidonT3");
  const poseidonT3 = await PoseidonT3.deploy();
  const PoseidonT6 = await ethers.getContractFactory("PoseidonT6");
  const poseidonT6 = await PoseidonT6.deploy();
  // PoseidonT3 address: 0x5FbDB2315678afecb367f032d93F642f64180aa3
  // PoseidonT6 address: 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
  // Semaphore address: 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
  // const depth = 20;
  // const externalNullifier = 1121212;
  // const Semaphore = await ethers.getContractFactory("Semaphore", {
  //   libraries: {
  //     PoseidonT3: poseidonT3.address,
  //     PoseidonT6: poseidonT6.address,
  //   },
  // });
  // const semaphore = await Semaphore.deploy(depth, externalNullifier);
  console.log("PoseidonT3 address:", poseidonT3.address);
  console.log("PoseidonT6 address:", poseidonT6.address);
  //console.log("Semaphore address:", semaphore.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
