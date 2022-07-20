const { task } = require("hardhat/config");

task("block-number", "Prints the current block number").setAction(
  // hre is hardhat runtime enviroment and can access a lot of package that hardhat can
  async (taskArgs, hre) => {
    const blockNumber = await hre.ethers.provider.getBlockNumber();
    console.log(`Current block number: ${blockNumber}`);
  }
);
