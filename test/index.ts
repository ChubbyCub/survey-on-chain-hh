import { ethers } from "hardhat";
const { expect } = require("chai");

describe("Platform contract", function () {
  it("Sign in to platform should create only one result view for surveyor", async function () {
    const [owner] = await ethers.getSigners();
    const Utils = await ethers.getContractFactory("Utils");
    const utils = Utils.deploy();
    const utilsAddress = (await utils).address;
    const Platform = await ethers.getContractFactory("Platform", {
      libraries: {
        Utils: utilsAddress,
      },
    });

    const platform = await Platform.deploy();

    await platform.signInAsSurveyor();
    await platform.signInAsSurveyor();
  });
});
