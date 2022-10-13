const { network } = require("hardhat")
const { networkConfig, developementChain } = require("../helper-hardhat-config")
require("dotenv").config()
const { verify } = require("../utils/verify")

module.exports = async (/*hre*/ { getNamedAccounts, deployments }) => {
  //const {getNamedAccounts, deployments} = hre;  //same as: hre.getNamedAccounts and hre.deployments
  //hre is hardhat runtime environment and getNamedAccounts,deployments are deployment objects
  //we are using  functions deploy,log from deployments deployment object
  //we are using  function deployer from deployments getNamedAccounts function
  const { deploy, log, get } = deployments
  const { deployer } = await getNamedAccounts()
  const chainId = network.config.chainId

  let ethUsdPriceFeedAddress
  if (developementChain.includes(network.name)) {
    //next line checks whether we deployed mock or not
    //mock contract is for networks which does not have ETH/USD addresses(Pricefeed contract addresses) eg. hardhat, localhost
    const ethUsdAggregator = await get("MockV3Aggregator") //It is contract //we can get most recent deployment of MockV3Aggregator contract by this line
    ethUsdPriceFeedAddress = ethUsdAggregator.address
  } else {
    ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"]
  }
  //if the contract  dosen't exist, we deploy minimal version of it for our local testing

  //if chainId is x then use address y
  //if chainId is z then use address a

  //what happens when we want to change chains
  //when going forlocalhost or hardhat network we want to use a mock

  const args = [ethUsdPriceFeedAddress]

  const fundMe = await deploy("FundMe", {
    from: deployer,
    args: args, //put pricefeed address
    log: true,
    waitConformations: network.config.blockConfirmations || 1,
  })
  if (
    !developementChain.includes(network.name) &&
    process.env.ETHERSCAN_API_KEY
  ) {
    await verify(fundMe.address, args)
  }
  log("-------------------------------------")
}

module.exports.tags = ["all", "fundme"]
