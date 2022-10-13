const { deployMockContract } = require("ethereum-waffle")
const { network } = require("hardhat")
const {
  developementChain,
  DECIMALS,
  INITIAL_ANSWER,
} = require("../helper-hardhat-config")

module.exports = async (/*hre*/ { getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments
  const { deployer } = await getNamedAccounts()
  const chainId = network.config.chainId

  if (developementChain.includes(network.name)) {
    log("Local Network detected Deploying mocks")
    await deploy("MockV3Aggregator", {
      contract: "MockV3Aggregator",
      from: deployer,
      log: true,
      args: [DECIMALS, INITIAL_ANSWER],
    })
    log("Mock Deployed")
    log("-------------------------------------------")
  }
}

module.exports.tags = ["all", "mocks"]

//This is script to deploy mock contract for networks which does not have ETH/USD addresses(Pricefeed contract addresses) eg. hardhat, localhost
//Pricefeed contracts are used to get latest pricings and price conversions of blockchain eg.ethereum
