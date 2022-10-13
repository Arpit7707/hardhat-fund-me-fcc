const networkConfig = {
  5: {
    name: "goerli",
    ethUsdPriceFeed: "0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e", //from https://docs.chain.link/docs/data-feeds/price-feeds/addresses/?network=ethereum
  },
  137: {
    name: "polygon",
    ethUsdPriceFeed: "0xF9680D99D6C9589e2a93a78A04A279e509205945", //from https://docs.chain.link/docs/data-feeds/price-feeds/addresses/?network=polygon
  },
}

const developementChain = ["hardhat", "localhost"]

const DECIMALS = 8
const INITIAL_ANSWER = 200000000

module.exports = {
  networkConfig,
  developementChain,
  DECIMALS,
  INITIAL_ANSWER,
}
