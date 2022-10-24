// Traditional way
// import
// main function
// call main function

// async function deployFunc() {
//   console.log("Hello!");
// }

// module.exports.default = deployFunc;

// This syntax is just a different way to write the above deployFunc() by using anonymous function instead
// module.exports = async (hre) => {
//   // hre is hardhat runtime enviroment, hardhat deploy automatically calls this function everytime we run hardhat deploy and automatically passes the hardhat object into it
//   const { getNamedAccounts, deployments } = hre;
// };

const {
  networkConfig,
  developmentChains,
} = require("../helper-hardhat-config");
const { network } = require("hardhat");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments;
  // getNamedAccounts is a way to get named accounts
  const { deployer } = await getNamedAccounts();
  const chainId = network.config.chainId;

  // if chainId is X use address Y...
  //   const ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"];
  // Flip between local, testnet and mainnet chain
  let ethUsdPriceFeedAddress;
  if (developmentChains.includes(network.name)) {
    const ethUsdAggregator = await deployments.get("MockV3Aggregator");
    ethUsdPriceFeedAddress = ethUsdAggregator.address;
  } else {
    ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"];
  }

  // if the contract doesn't exist, we deploy a minimal version of it for local testing

  // when going for localhost or hardhat network we want to use a mock
  const fundMe = await deploy("FundMe", {
    from: deployer,
    args: [ethUsdPriceFeedAddress], // put price feed address,
    log: true,
  });
  log("------------------------------");
};

module.exports.tags = ["all", "fundme"];
