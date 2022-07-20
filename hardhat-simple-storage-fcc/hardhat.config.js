require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
require("@nomiclabs/hardhat-etherscan");
require("./tasks/block-number");
require("hardhat-gas-reporter");
require("solidity-coverage");

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// const RINKEBY_RPC_URL = process.BY_RPC_URL || "https://eth-rinkeby";
// const PRIVATE_KEY = process.env.PRIVATE_KEY || "0xkey";
// const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY || "key";
// const COINMARKETCAP_API_KEY = process.env.COINMARKETCAP_API_KEY || "key";

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  // This is added by default, you don't need to explicitly define it
  defaultNetwork: "hardhat",
  // How to add additional networks example
  networks: {
    // rinkeby: {
    //   url: RINKEBY_RPC_URL,
    //   accounts: [PRIVATE_KEY],
    //   chainId: 4,
    // },
    // For the local network created with yarn hardhat node command
    // It doesn't need accounts, because hardhat already places them in
    localhost: {
      url: "http://127.0.0.1:8545/",
      chainId: 31337,
    },
  },
  solidity: "0.8.8",
  // etherscan: {
  //   apiKey: ETHERSCAN_API_KEY,
  // },
  // Use the gas reporter with your tests
  gasReporter: {
    enabled: false,
    outputFile: "gas-report.txt",
    noColors: true,
    // Get the cost of the transaction under the current prices
    // currency: "USD",
    // coinmarketcap: COINMARKETCAP_API_KEY,
    // token: "MATIC",
  },
};
