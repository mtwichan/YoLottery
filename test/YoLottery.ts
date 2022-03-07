const hre = require("hardhat");
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
  describe("Quick Test", function () {
    it("Test", async function () {
      await instance.createPool(1, 60, ethers.utils.parseEther("0.5"));
      await instance.startPool(1);
      await hre.ethers.provider.send("evm_increaseTime", [2]);
      await instance.depositPool(1, { value: ethers.utils.parseEther("2.5") });
      await instance.connect(addr1).depositPool(1, { value: ethers.utils.parseEther("1") });
      await instance.connect(addr2).depositPool(1, { value: ethers.utils.parseEther("2") });
      await hre.ethers.provider.send("evm_increaseTime", [61]);
      await instance.distributePool(1);

      const tx = await instance.withdraw();
      const rc = await tx.wait();

      const event = rc.events?.find((event) => event.event === "Withdrawl");
      const [sender, withdrawedFunds] = event?.args!;
      console.log(
        "Result of withdrawl event fired >>> ",
        sender,
        withdrawedFunds
      );
    });
  });
  describe("Deployment", () => {
    it("Deployment ...", () => {
      console.log("...");
    });
  });

  // describe("Pool deposit interactions", () => {
  //   it("Should deposit 1ETH to the pool", async () => {
  //     await instance.depositPool(1, { value: 1 });

  //     expect(await instance.getContractBalance()).to.equal(1);
  //     expect(await instance.getBalance(1)).to.equal(1);
  //     expect(await instance.getOwedAmount(1)).to.equal(0);
  //   });

  //   it("Should not be able to deposit more than account balance", async () => {
  //     console.log("Balance owner >>>", await owner.getBalance());
  //     await expect(
  //       instance.depositPool(1, {
  //         from: owner.getAddress(),
  //         value: ethers.utils.parseEther("100.0"),
  //       })
  //     ).to.be.revertedWith("Ensure sender has enough funds to put in pool");
  //   });
  // });

  // describe("Pool distribution interactions", () => {
  //   it("Should distribute money in the pool", async () => {
  //     await instance.depositPool(1, { value: 231 });
  //     await instance.connect(addr1).depositPool(1, { value: 123 });
  //     await instance.connect(addr2).depositPool(1, { value: 312 });

  //     await instance.distributePool(1);

  //     expect(await instance.getBalance(1)).to.equal(0);
  //     expect(await instance.connect(addr1).getBalance(1)).to.equal(0);

  //     expect(await instance.getOwedAmount(1)).to.equal(
  //       ethers.utils.parseEther("1.0")
  //     );
  //     expect(await instance.connect(addr1).getOwedAmount(1)).to.equal(
  //       ethers.utils.parseEther("1.0")
  //     );
  //   });
  // });

  // describe("Pool withdrawl interactions", () => {
  //   it("Should withdraw funds from the pool to user account", async () => {
  //     await instance.depositPool(1, { value: ethers.utils.parseEther("1.0") });
  //     await instance
  //       .connect(addr1)
  //       .depositPool(1, { value: ethers.utils.parseEther("2.0") });
  //     await instance
  //       .connect(addr2)
  //       .depositPool(1, { value: ethers.utils.parseEther("3.0") });
  //     await instance.distributePool(1);

  //     const tx = await instance.withdraw(1);
  //     const rc = await tx.wait();

  //     const event = rc.events?.find((event) => event.event === "Withdrawl");
  //     const [sender, withdrawedFunds] = event?.args!;
  //     console.log(
  //       "Result of withdrawl event fired >>> ",
  //       sender,
  //       withdrawedFunds
  //     );

  //     expect(withdrawedFunds).to.equal(ethers.utils.parseEther("1.0"));
  //     expect(sender).to.equal(await owner.getAddress());
  //   });
  // });
});
