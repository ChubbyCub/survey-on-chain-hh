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
  // npx hardhat run scripts/Platform.ts --network localhost
  // 0xE09B4d15a1BADB4c019a179478128F9fe74ef454  T3
  // 0x20B79274b2B25AdD5bF356B5daE59ce0442ce0b1  T6
  // 0xc2Dc58A6811f94B23e7F810847b670271721Ee1e  Semaphore
  // 0x427d37a6009342DbcB9175Fd511a6Fdc7A9Fbcf9  Utils
  // 0x802c4CDc73B9A6c3dcAbda428303295f850e9c68  Platform

  // Utils address: 0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9
  // Platform address: 0xA51c1fc2f0D1a1b8494Ed1FE312d7C3a78Ed91C0

  const Utils = await ethers.getContractFactory("Utils");
  const utils = await Utils.deploy();

  console.log("Utils address:", utils.address);

  const Platform = await ethers.getContractFactory("Platform", {
    libraries: {
      Utils: utils.address,
    },
  });
  const platform = await Platform.deploy();

  console.log("Platform address:", platform.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
