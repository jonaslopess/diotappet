// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.22 <0.9.0;
//pragma experimental ABIEncoderV2;

/** 
 * @title LogisticsResource
 * @dev Represents a logistics resource on the DLT
 */
contract LogisticsResource {

    struct MonitoringCapability {
        // data used to represent monitoring capabilities of the logistics resource
        string keyWord; // unique identification to monitoring capability
        string description; // shor description about the monitoring capability
        int currentValue; // last value colected by the sensors about this monitoring capability
        bool exists; // verify if the monitoring capability was already added
    }

    address private owner;

    mapping(bytes32 => MonitoringCapability) private monitoringCapabilities;
    string[] private keyWords;

    string[] private productBatches;


    string[] private position;
    int private length;
    int private width;
    int private height;
    
    int private wheight;


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
     * @dev Add a new monitoring capability 
     * @param _keyWord keyword of a monitoring capability
     * @param _description description of a monitoring capability
     */
    function addMonitoringCpability(string memory _keyWord, string memory _description) public onlyOwner
    {
        keyWords.push(_keyWord);
        monitoringCapabilities[keccak256(abi.encodePacked(_keyWord))] = (MonitoringCapability({
            keyWord: _keyWord,
            description: _description,
            currentValue: 0,
            exists: true
        }));
    }

    /** 
     * @dev Add a new product batch 
     * @param _code code of a product batch
     */
    function addProductBatch(string memory _code) public onlyOwner
    {
        productBatches.push(_code);
        //...
    }


    /** 
     * @dev Provides iot device monitoring capabilities visibility 
     * @return monitoringCapabilities_ comma-separated string with all available monitoring capabilities
     */
    function getMonitoringCapabilities() public view
            returns (string memory)
    {
        string memory keyWords_ = keyWords[0];
        
        for (uint i = 1; i < keyWords.length; i++) {
            keyWords_ = string(abi.encodePacked(keyWords_, ", ", keyWords[i]));
        }
        return (keyWords_);
    }

    /** 
     * @dev Update the value of a iot device monitoring capability
     * @param _keyWord keyword of a monitoring capability
     * @param _value current value for a monitoring capability
     */
    function setMonitoringValue(string memory _keyWord, int _value) public onlyOwner
    {
        bytes32 key = keccak256(abi.encodePacked(_keyWord));
        if(monitoringCapabilities[key].exists)
            monitoringCapabilities[key].currentValue = _value;
    }

    /** 
     * @dev Provides iot device monitoring capability value visibility 
     * @param _keyWord keyword of a monitoring capability
     * @return monitoringCapabilityValue_ uint of the monitoring capability current value
     */
    function getMonitoringValue(string memory _keyWord) public view
            returns (int)
    {
        bytes32 key = keccak256(abi.encodePacked(_keyWord));
        if(monitoringCapabilities[key].exists)
            return monitoringCapabilities[key].currentValue;
        else
            return 0;
    }

}