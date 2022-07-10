// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
// ABI binary interface just like API but for block chain to get the latest price of ethereum
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract FundMe {

    mapping(address => uint256) public addressToAmountFunded;
    address public owner;
    address[] public funders;
    constructor() public{
        owner = msg.sender;
    }

    function fund() public payable{
        //50$
        uint256 minimumUSD = 0.5*10**18;
        require(getConversionRate(msg.value)>=minimumUSD,"you need to spend more eth");
        addressToAmountFunded[msg.sender]+=msg.value;
        funders.push(msg.sender);
    }

    function getVersion() public view returns(uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        return priceFeed.version();
    }
    function getPrice() public view returns(uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        (
            ,
            int price,
            ,
            ,
        ) = priceFeed.latestRoundData();
        return uint256(price*10000000000);
    }
    
    function getConversionRate(uint256 ethAmount) public view returns(uint256){
        uint256 ethPrice = getPrice();
        uint256 ethAmountUsd = (ethPrice*ethAmount)/1000000000000000000;
        return ethAmountUsd;
    }
    //modifiers are used to change the behaviour of a function in a declarative way
    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }
    function withdraw() payable onlyOwner public{
        payable(msg.sender).transfer(address(this).balance);
        for(uint256 funderIndex=0;funderIndex<funders.length;funderIndex++){
            addressToAmountFunded[funders[funderIndex]]=0;
        }
        funders = new address[](0);
    }

}
