// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.22 <0.9.0;
//pragma experimental ABIEncoderV2;

/** 
 * @title LogisticsResource
 * @dev Represents a logistics resource on the DLT
 */
contract LogisticsResource {
    struct Rule {
        // data used to represent a transport or storage condition of the product batch
        uint id; // rule index on the auxiliary iterable array
        string monitoredProperty; // monitored property unique identification 
        int maxValue; // property maximun value to verify the rule
        int minValue; // property minimun value to verify the rule
        bool exists; // verify if the rule was already added
    }

    struct ProductBatch {
        // data used to represent a product batch
        string code; // product batch unique identification 
        uint id; // batch index on the auxiliary iterable array
        bool exists; // verify if the batch was already added
    }

    struct MonitoringCapability {
        // data used to represent monitoring capabilities of the vehicle/cargo compartment
        string keyWord; // unique identification to monitoring capability
        string description; // short description about the monitoring capability
        int currentValue; // last value colected by the sensors about this monitoring capability
        bool exists; // verify if the monitoring capability was already added
    }

    address private owner;
    
    mapping(bytes32 => MonitoringCapability) private monitoringCapabilities;
    string[] private keyWords;

    mapping(bytes32 => ProductBatch) private productBatches;
    string[] private batchCodes;

    mapping(bytes32 => mapping(bytes32 => Rule)) private rules;
    mapping(bytes32 => string[]) private monitoredProperties;

    uint private status; // [0] available or [1] in use or [2] rule violated or [3] out of operation

    //event StartMonitoring();
    //event StopMonitoring();
    event RuleViolation(string indexed _productBatchCode, string _monitoredProperty, string _rule, int _value);
    event BatchAdded(string indexed _productBatchCode);
    event BatchRemoved(string indexed _productBatchCode);
    //event MonitoredPropertyChange(string _monitoredProperty, int _value);

    /** 
     * @dev Create a new logistcs resource
     */
    constructor( ) public {
        owner = msg.sender;
        status = 0;
        batchCodes = new string[](0);
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Ownable: You are not the owner, Bye.");
        _;
    }

    /** 
     * @dev Provides logistics resource owner
     * @return owner_
     */
    function getOwner() public view
            returns (address owner_)
    {
        return owner;
    }

    /** 
     * @dev Disable logistics resource
     * @return status_
     */
    function disableLogisticsResource() public onlyOwner
            returns (uint status_)
    {
        status = 3;
        return status;
    }

    /** 
     * @dev Provides logistics resource status
     * @return status_
     */
    function getStatus() public view
            returns (uint status_)
    {
        return status;
    }

    /** 
     * @dev Add a new monitoring capability 
     * @param _keyWord keyword of a monitoring capability
     * @param _description description of a monitoring capability
     */
    function addMonitoringCapability(string memory _keyWord, string memory _description) public onlyOwner
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
     * @dev Provides logistics resource monitoring capabilities visibility 
     * @return monitoringCapabilities_ comma-separated string with all available monitoring capabilities
     */
    function getMonitoringCapabilities() public view
            returns (string memory)
    {
        if(keyWords.length > 0) {
            string memory keyWords_ = keyWords[0];
            
            for (uint i = 1; i < keyWords.length; i++) {
                keyWords_ = string(abi.encodePacked(keyWords_, ", ", keyWords[i]));
            }
            return (keyWords_);
        
        } else {
            return "No monitoring capabilities registered yet.";
        }
    }

    /** 
     * @dev Update the value of a logistics resource monitoring capability
     * @param _keyWord keyword of a monitoring capability
     * @param _value current value for a monitoring capability
     */
    function setMonitoringValue(string memory _keyWord, int _value) public onlyOwner
    {
        bytes32 key = keccak256(abi.encodePacked(_keyWord));
        if(status != 3 && monitoringCapabilities[key].exists){
            monitoringCapabilities[key].currentValue = _value;
            //emit MonitoredPropertyChange(_keyWord, _value);
            if(batchCodes.length > 0){
                if(!checkBatches(_keyWord, _value)){
                    status = 2;
                }
            } else {
                status = 0;
            }
        }
    }

    /** 
     * @dev Provides logistics resource monitoring capability value visibility 
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

    /** 
     * @dev Add a new product batch
     * @param _code code of a product batch
     */
    function addProductBatch(string memory _code) public onlyOwner
    {
        batchCodes.push(_code);
        bytes32 key = keccak256(abi.encodePacked(_code));
        productBatches[key] = (ProductBatch({
            code: _code,
            id: batchCodes.length-1,
            exists: true
        }));
        emit BatchAdded(_code);
        status = 1;
    }

    

    /** 
     * @dev Remove a product batch
     * @param _code code of a product batch
     */
    function removeProductBatch(string memory _code) public onlyOwner
    {
        bytes32 batchKey = keccak256(abi.encodePacked(_code));
        uint id = productBatches[batchKey].id;
        delete productBatches[batchKey];
        for (uint i = id; i<batchCodes.length-1; i++){
            batchCodes[i] = batchCodes[i+1];
        }
        batchCodes.pop();

        if(batchCodes.length == 0)
            status = 0;
        
        for (uint i = 0; i<monitoredProperties[batchKey].length; i++){
            bytes32 ruleKey = keccak256(abi.encodePacked(monitoredProperties[batchKey][i]));
            delete rules[batchKey][ruleKey];
        }
        
        delete monitoredProperties[batchKey];
        emit BatchRemoved(_code);
    }

    /** 
     * @dev Add a new rule 
     * @param _batchCode product baych code unique identification
     * @param _monitoredProperty monitored property unique identification
     * @param _maxValue property maximun value to verify the rule
     * @param _minValue property minimun value to verify the rule
    */
    function addRule(
        string memory _batchCode,
        string memory _monitoredProperty,
        int _maxValue,
        int _minValue
    ) public onlyOwner
    {
        bytes32 batchKey = keccak256(abi.encodePacked(_batchCode));
        if(productBatches[batchKey].exists){
            monitoredProperties[batchKey].push(_monitoredProperty);
            bytes32 ruleKey = keccak256(abi.encodePacked(_monitoredProperty));
            rules[batchKey][ruleKey] = (Rule({
                id: monitoredProperties[batchKey].length-1,
                monitoredProperty: _monitoredProperty,
                maxValue: _maxValue,
                minValue: _minValue,
                exists: true
            }));
        }
    }

    /** 
     * @dev Check the rule given a product batch code, a property and a value
     * @param _monitoredProperty keyword of a monitored property
     * @param _monitoredValue value of a monitored property
     * @return fulfilledRule_ boolean value of the rule compliance
     */
    function checkRule(
        string memory _batchCode,
        string memory _monitoredProperty, 
        int _monitoredValue
    ) public 
            returns (bool)
    {
        bool fulfilledRule_ = true;

        bytes32 batchKey = keccak256(abi.encodePacked(_batchCode));
        if(productBatches[batchKey].exists){
            bytes32 ruleKey = keccak256(abi.encodePacked(_monitoredProperty));
            if(rules[batchKey][ruleKey].exists){
                if(rules[batchKey][ruleKey].maxValue < _monitoredValue){
                    emit RuleViolation(
                        _batchCode, 
                        _monitoredProperty, 
                        "MAX", 
                        rules[batchKey][ruleKey].maxValue
                    );
                    fulfilledRule_ = false;
                } 
                if(rules[batchKey][ruleKey].minValue > _monitoredValue){
                    emit RuleViolation(
                        _batchCode, 
                        _monitoredProperty, 
                        "MIN", 
                        rules[batchKey][ruleKey].minValue
                    );
                    fulfilledRule_ = false;
                }
            }     
        }        
        return fulfilledRule_; 
    }

    /** 
     * @dev Check the rules of each product batch given a property and a value
     * @param _monitoredProperty keyword of a monitored property
     * @param _monitoredValue value of a monitored property
     * @return fulfilledRules_ boolean value of the rules compliance
     */
    function checkBatches(
        string memory _monitoredProperty, 
        int _monitoredValue
    ) public
            returns (bool fulfilledRules_)
    {
        fulfilledRules_ = true;
    
        for (uint i = 0; i < batchCodes.length; i++) {
            fulfilledRules_ = checkRule(batchCodes[i], _monitoredProperty, _monitoredValue);
        }
        return (fulfilledRules_);
     
    }

    /** 
     * @dev Provides product batches visibility 
     * @return batches_ comma-separated string with all batches
     */
    function getBatches() public view
            returns (string memory)
    {
        if(batchCodes.length > 0) {
            string memory batches_ = batchCodes[0];
        
            for (uint i = 1; i < batchCodes.length; i++) {
                batches_ = string(abi.encodePacked(
                    batches_, 
                    ", ", 
                    batchCodes[i]
                ));
            }
            return (batches_);
        } else {
            return "No batches registered yet.";
        }
     
    }

    /** 
     * @dev Provides product batch rules visibility 
     * @param _batchCode keyword of a monitored property 
     * @return rules_ comma-separated string with all rules
     */
    function getRules(string memory _batchCode) public view
            returns (string memory)
    {
        bytes32 batchKey = keccak256(abi.encodePacked(_batchCode));
        if(productBatches[batchKey].exists){
            if(monitoredProperties[batchKey].length > 0) {       
                string memory rules_ = monitoredProperties[batchKey][0];
                for (uint i = 1; i < monitoredProperties[batchKey].length; i++) {
                    rules_ = string(abi.encodePacked(
                        rules_,
                        ", ",
                        monitoredProperties[batchKey][i]
                    ));
                }
                return (rules_);
            } else {
                return "No rules registered yet.";
            }
        } else {
            return "Batch not found";
        }
    }

    /** 
     * @dev Provides a product batch rule visibility 
     * @param _batchCode keyword of a monitored property 
     * @param _monitoredProperty keyword of a monitored property 
     * @return minValue_ rule minimun value
     * @return maxValue_ rule maximun value
     */
    function getRule(string memory _batchCode, string memory _monitoredProperty) public view
            returns (int minValue_, int maxValue_)
    {
        bytes32 batchKey = keccak256(abi.encodePacked(_batchCode));
        bytes32 ruleKey = keccak256(abi.encodePacked(_monitoredProperty));
        if(rules[batchKey][ruleKey].exists){
            return (rules[batchKey][ruleKey].minValue, rules[batchKey][ruleKey].maxValue);
        } else {
            return (0,0);
        }
    }
}