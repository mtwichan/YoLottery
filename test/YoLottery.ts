import { expect } from "chai";
import { ethers } from "hardhat";
import { YoLottery__factory, YoLottery } from "../typechain";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

describe("YoLottery", function () {
  let YoLottery;
  let instance: YoLottery;
  let owner: SignerWithAddress;
  let addr1: SignerWithAddress;
  let addr2: SignerWithAddress;
  let addrs: SignerWithAddress[];

  beforeEach("Deploy fresh contract", async () => {
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
    YoLottery = (await ethers.getContractFactory(
      "YoLottery",
      owner
    )) as YoLottery__factory;
    instance = await YoLottery.deploy();

    console.log("YoLottery deployed to:", instance.address);
  });

  describe("Deployment", () => {
    it("Should", () => {
      console.log("do something");
    });
  });

  describe("Pool deposit interactions", () => {
    it("Should deposit 1ETH to the pool", async () => {
      await instance.depositPool(1, { value: 1 });

      expect(await instance.getContractBalance()).to.equal(1);
      expect(await instance.getBalance(1)).to.equal(1);
      expect(await instance.getOwedAmount(1)).to.equal(0);
    });

    it("Should not be able to deposit more than account balance", async () => {
      console.log("Balance owner >>>", await owner.getBalance());
      await expect(
        instance.depositPool(1, { from: owner.getAddress(), value: 9999999 })
      ).to.be.revertedWith("Ensure sender has enough funds to put in pool");
    });
  });

  describe("Pool distribution interactions", () => {
    it("Should distribute money in the pool", async () => {
        console.log("...");
      });
  });

  it("Should withdraw funds from the pool to user account", async () => {
    console.log("...");
  });
});
