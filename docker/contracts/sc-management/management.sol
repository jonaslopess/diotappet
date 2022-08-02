// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.22 <0.9.0;
//pragma experimental ABIEncoderV2;

/** 
 * @title Management Contract
 * @dev Represents a IoT device on DLT
 */
contract ManagementContract {

    struct LogisticsResource {
        // data used to represent monitoring capabilities of the iot device
        string keyWord; // unique identification to monitoring capability
        string description; // shor description about the monitoring capability
        address contractAddress; // last value colected by the sensors about this monitoring capability
        bool exists; // verify if the monitoring capability was already added
    }

    address private owner;    

    mapping(address => LogisticsResource) private logisticsResources;
    address[] private contractAdresses;

    /** 
     * @dev Create a new iot device
     */
    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Ownable: You are not the owner, Bye.");
        _;
    }

    /** 
     * @dev Provides iot device owner
     * @return owner_
     */
    function getOwner() public view
            returns (address owner_)
    {
        return owner;
    }

    /** 
     * @dev Add a new logistics resource
     * @param _keyWord keyword of a logistics resource
     * @param _description description of a logistics resource
     * @param _contractAddress contract address of a logistics resource
     */
    function addLogisticsResource(string memory _keyWord, string memory _description, address _contractAddress) public onlyOwner
    {
        contractAdresses.push(_contractAddress);
        logisticsResources[_contractAddress] = (LogisticsResource({
            keyWord: _keyWord,
            description: _description,
            contractAddress: _contractAddress,
            exists: true
        }));
    }


    /** 
     * @dev Provides logistics resources visibility 
     * @return logisticsResources_ comma-separated string with all available logistics resources
     */
    function getLogisticsResources() public view
            returns (address [] memory)
    {
        return (contractAdresses);
    }

}