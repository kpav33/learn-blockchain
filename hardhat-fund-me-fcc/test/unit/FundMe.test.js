const { network, deployments, ethers, getNamedAccounts } = require("hardhat");
const { assert, expect } = require("chai");
const { developmentChains } = require("../../helper-hardhat-config");

describe("FundMe", async function () {
  let fundMe;
  let deployer;
  let mockV3Aggregator;
  const sendValue = ethers.utils.parseEther("1"); // 1 eth

  beforeEach(async function () {
    // deploy our fundMe contract
    // using Hardhat-deploy
    // const accounts = await ethers.getSigners()
    // const accountZero = accounts[0]
    deployer = (await getNamedAccounts()).deployer;
    await deployments.fixture(["all"]);
    fundMe = await ethers.getContract("FundMe", deployer);
    mockV3Aggregator = await ethers.getContract("MockV3Aggregator", deployer);
  });

  describe("constructor", async function () {
    it("sets the aggregator addresses correctly", async () => {
      const response = await fundMe.s_priceFeed();
      assert.equal(response, mockV3Aggregator.address);
    });
  });

  describe("fund", function () {
    // https://ethereum-waffle.readthedocs.io/en/latest/matchers.html
    // could also do assert.fail
    it("Fails if you don't send enough ETH", async () => {
      await expect(fundMe.fund()).to.be.revertedWith(
        "You need to spend more ETH!"
      );
    });
    // we could be even more precise here by making sure exactly $50 works
    // but this is good enough for now
    it("Updates the amount funded data structure", async () => {
      await fundMe.fund({ value: sendValue });
      const response = await fundMe.s_addressToAmountFunded(deployer);
      assert.equal(response.toString(), sendValue.toString());
    });
    it("Adds funder to array of funders", async () => {
      await fundMe.fund({ value: sendValue });
      const response = await fundMe.s_funders(0);
      assert.equal(response, deployer);
    });
  });

  describe("withdraw", function () {
    // First add some money to the contract, so you can test withdrawing
    beforeEach(async () => {
      await fundMe.fund({ value: sendValue });
    });

    it("withdraws ETH from a single funder", async () => {
      // Arrange
      // fundMe contract has a provider that gets us the balance of the contract
      const startingFundMeBalance = await fundMe.provider.getBalance(
        fundMe.address
      );
      const startingDeployerBalance = await fundMe.provider.getBalance(
        deployer
      );

      // Act
      // call withdraw function and get the gas used and the gas price from the receipt
      const transactionResponse = await fundMe.withdraw();
      const transactionReceipt = await transactionResponse.wait(1);
      const { gasUsed, effectiveGasPrice } = transactionReceipt;
      const gasCost = gasUsed.mul(effectiveGasPrice);

      const endingFundMeBalance = await fundMe.provider.getBalance(
        fundMe.address
      );
      const endingDeployerBalance = await fundMe.provider.getBalance(deployer);

      // Assert
      // make sure the money goes to the right places
      assert.equal(endingFundMeBalance, 0);
      assert.equal(
        startingFundMeBalance.add(startingDeployerBalance).toString(),
        endingDeployerBalance.add(gasCost).toString()
      );
    });

    // this test is overloaded. Ideally we'd split it into multiple tests
    // but for simplicity we left it as one
    it("is allows us to withdraw with multiple funders", async () => {
      // Arrange
      const accounts = await ethers.getSigners();
      // loop through accounts and set each account to call fund function
      for (i = 1; i < 6; i++) {
        const fundMeConnectedContract = await fundMe.connect(accounts[i]);
        await fundMeConnectedContract.fund({ value: sendValue });
      }
      const startingFundMeBalance = await fundMe.provider.getBalance(
        fundMe.address
      );
      const startingDeployerBalance = await fundMe.provider.getBalance(
        deployer
      );

      // Act
      // const transactionResponse = await fundMe.cheaperWithdraw();
      // Let's compare gas costs :)
      const transactionResponse = await fundMe.withdraw();
      const transactionReceipt = await transactionResponse.wait(1);
      const { gasUsed, effectiveGasPrice } = transactionReceipt;
      const withdrawGasCost = gasUsed.mul(effectiveGasPrice);
      console.log(`GasCost: ${withdrawGasCost}`);
      console.log(`GasUsed: ${gasUsed}`);
      console.log(`GasPrice: ${effectiveGasPrice}`);
      const endingFundMeBalance = await fundMe.provider.getBalance(
        fundMe.address
      );
      const endingDeployerBalance = await fundMe.provider.getBalance(deployer);
      // Assert
      assert.equal(
        startingFundMeBalance.add(startingDeployerBalance).toString(),
        endingDeployerBalance.add(withdrawGasCost).toString()
      );
      // Make a getter for storage variables
      await expect(fundMe.s_funders(0)).to.be.reverted;
      // await expect(fundMe.getFunder(0)).to.be.reverted;

      // Check that accounts balance is 0
      for (i = 1; i < 6; i++) {
        assert.equal(
          await fundMe.s_addressToAmountFunded(accounts[i].address),
          0
        );
      }
    });

    it("Only allows the owner to withdraw", async function () {
      const accounts = await ethers.getSigners();
      const attacker = accounts[1];
      const attackerConnectedContract = await fundMe.connect(attacker);
      await expect(attackerConnectedContract.withdraw()).to.be.reverted;
      // await expect(attackerConnectedContract.withdraw()).to.be.revertedWith(
      //   "FundMe__NotOwner"
      // );
      // const fundMeConnectedContract = await fundMe.connect(accounts[1]);
      // await expect(fundMeConnectedContract.withdraw()).to.be.revertedWith(
      //   "FundMe__NotOwner"
      // );
    });

    it("cheaperWithdraw testing...", async () => {
      // Arrange
      const accounts = await ethers.getSigners();
      // loop through accounts and set each account to call fund function
      for (i = 1; i < 6; i++) {
        const fundMeConnectedContract = await fundMe.connect(accounts[i]);
        await fundMeConnectedContract.fund({ value: sendValue });
      }
      const startingFundMeBalance = await fundMe.provider.getBalance(
        fundMe.address
      );
      const startingDeployerBalance = await fundMe.provider.getBalance(
        deployer
      );

      // Act
      const transactionResponse = await fundMe.cheaperWithdraw();
      // Let's compare gas costs :)
      // const transactionResponse = await fundMe.withdraw();
      const transactionReceipt = await transactionResponse.wait(1);
      const { gasUsed, effectiveGasPrice } = transactionReceipt;
      const withdrawGasCost = gasUsed.mul(effectiveGasPrice);
      console.log(`GasCost: ${withdrawGasCost}`);
      console.log(`GasUsed: ${gasUsed}`);
      console.log(`GasPrice: ${effectiveGasPrice}`);
      const endingFundMeBalance = await fundMe.provider.getBalance(
        fundMe.address
      );
      const endingDeployerBalance = await fundMe.provider.getBalance(deployer);
      // Assert
      assert.equal(
        startingFundMeBalance.add(startingDeployerBalance).toString(),
        endingDeployerBalance.add(withdrawGasCost).toString()
      );
      // Make a getter for storage variables
      await expect(fundMe.s_funders(0)).to.be.reverted;
      // await expect(fundMe.getFunder(0)).to.be.reverted;

      // Check that accounts balance is 0
      for (i = 1; i < 6; i++) {
        assert.equal(
          await fundMe.s_addressToAmountFunded(accounts[i].address),
          0
        );
      }
    });
  });
});
