//SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@chainlink/contracts/src/v0.6/tests/MockV3Aggregator.sol";

//This is contract for networks which does not have ETH/USD addresses(Pricefeed contract addresses) eg. hardhat, localhost
//Pricefeed contracts are used to get latest pricings and price conversions of blockchain eg.ethereum
