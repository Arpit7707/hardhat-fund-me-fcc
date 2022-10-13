//Get funds from user
//Withdraw funds
//Set minimum funding value in USD

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./PriceConverter.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    //declaring variable a constant or immutable is gas efficient (ecreases gas prices), hence they are used for gas optimization

    uint256 public constant MINIMUM_USD = 50 * 1e18;

    AggregatorV3Interface private s_priceFeed; //s_ represents that they are storage variablesnand storing in storage costs too much gas
    //constant variable deployment gas - 21,415
    //non constant variable deployment gas - 23,515

    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmountFunded;

    address private immutable i_owner;

    //immuntable variable deployment gas - 21,508
    //non immuntable variable deployment gas - 23,644

    //constructor is called immediately after smart contract is deployed
    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    function fund() public payable {
        //Want to be able to set a minimum fund amount in USD
        //1. How do we send ETH to this contract?

        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "Didn't fund enough!"
        ); //1e18 == 1* 10^18 == 1000000000000000000
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;

        //What is reverting?
        //undo any action before, and send reamining gas back
    }

    //onlyOwner is modiifier
    //when the function is called, firstly statements in onlyOwner modifier will get executed then the remaining statements of the code will get executed
    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        //reset the array
        s_funders = new address[](0);

        //actually withdraw the funds

        //Method 1:transfer
        //msg.address = address (address of sender/funder)
        //payable(msg.sender) = payable address
        //address(this) is address of destination contract(address of smart contract)
        //payable(msg.sender).transfer(address(this).balance);

        //Method 2:send
        //bool sendSuccess = payable(msg.sender).send(address(this).balance);
        //require(sendSuccess, "Send failed"); //require() is Kind of conditional statement

        //Method 3:call
        //bytes objects are arrays, so dataReturned is declared as memory
        //call method returns two variables, 1.boolean 2.byte object with some data
        (
            bool callSuccess, /*bytes memory dataReturned*/

        ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    function cheaperWithdraw() public payable onlyOwner {
        address[] memory funders = s_funders;
        //mapping can't be in memory
        for (
            uint256 fundersIndex = 0;
            fundersIndex < funders.length;
            fundersIndex++
        ) {
            address funder = funders[fundersIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool success, ) = i_owner.call{value: address(this).balance}("");
        require(success, "Call failed");
    }

    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Sender is not owner");

        //this syntax is gas efficient
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner(); //NotOwner() error is declared at the top, outside of contract
        }
        _;
        //_ represents remaining code
        //when modifier is added in declaration of function then firstly the require statement is execurted and rest of the code is executed later
    }

    //What if someone sends this contract ETH without calling fund function

    //receive() is special function and don't require function keyword
    //we can send ETH to contract without making any function by receiver() sunction
    //receive() is triggered(executed) when we pay using transact after deploying this contract, while clicking transact CALLDATA should be blank
    receive() external payable {
        fund();
    }

    //fallback() is special function and don't require function keyword
    //If CALLDATA will not be empty then fallback function will be triggered(executed)
    fallback() external payable {
        fund();
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getFunders(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getAddressToAmountFunded(address funder)
        public
        view
        returns (uint256)
    {
        return s_addressToAmountFunded[funder];
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}
