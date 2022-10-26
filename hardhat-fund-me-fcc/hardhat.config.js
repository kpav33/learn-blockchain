require("@nomicfoundation/hardhat-toolbox");
require("hardhat-deploy");
require("hardhat-gas-reporter");

const COINMARKETCAP_API_KEY = process.env.COINMARKETCAP_API_KEY || "";
const GOERLI_RPC_URL =
  process.env.GOERLI_RPC_URL ||
  "https://eth-mainnet.alchemyapi.io/v2/your-api-key";
const PRIVATE_KEY =
  process.env.PRIVATE_KEY ||
  "0x11ee3108a03081fe260ecdc106554d09d9d1209bcafd46942b10e02943effc4a";
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY || "";

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  // solidity: "0.8.8",
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 31337,
      // gasPrice: 130000000000,
    },
    goerli: {
      url: GOERLI_RPC_URL,
      accounts: [PRIVATE_KEY],
      chainId: 5,
      blockConfirmations: 6,
    },
  },
  solidity: {
    compilers: [{ version: "0.8.8" }, { version: "0.6.6" }],
  },
  namedAccounts: {
    deployer: {
      default: 0,
    },
    user: {
      default: 1,
    },
  },
  gasReporter: {
    enabled: true,
    currency: "USD",
    outputFile: "gas-report.txt",
    noColors: true,
    // coinmarketcap: COINMARKETCAP_API_KEY,
  },
};
