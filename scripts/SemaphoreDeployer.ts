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

  const SemaphoreDeployer = await ethers.getContractFactory(
    "SemaphoreDeployer",
    {
      libraries: {
        PoseidonT3: poseidonT3.address,
        PoseidonT6: poseidonT6.address,
      },
    }
  );
  const semaphoreDeployer = await SemaphoreDeployer.deploy();
  console.log("Semaphore address:", semaphoreDeployer.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });