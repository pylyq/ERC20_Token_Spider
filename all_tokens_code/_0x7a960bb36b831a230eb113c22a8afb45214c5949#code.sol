//token_name	
//token_url	https://etherscan.io//address/0x7a960bb36b831a230eb113c22a8afb45214c5949#code
//spider_time	2018/07/08 12:15:40
//token_Transactions	1 txn
//token_price	

pragma solidity ^0.4.15;

    /****************************************************************
     *
     * Name of the project: Genevieve GXE ICO
     * Contract name: NewIco
     * Author: Juan Livingston @ Ethernity.live
	 *
     ****************************************************************/

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  function burn(address spender, uint256 value) returns (bool); // Optional 
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ERC223 {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  
  function name() constant returns (string _name);
  function symbol() constant returns (string _symbol);
  function decimals() constant returns (uint8 _decimals);
  function totalSupply() constant returns (uint256 _supply);

  function transfer(address to, uint value) returns (bool ok);
  function transfer(address to, uint value, bytes data) returns (bool ok);
  function transfer(address to, uint value, bytes data, string custom_fallback) returns (bool ok);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
}

contract Whitelist {
  mapping (address => bool) public registered;
}

contract GXESwapper{

    address public authorizedCaller;
    address public collectorAddress;
    address public owner;
    address public whitelistAdd;

    address public tokenAdd; 
    address public tokenSpender;

    uint public initialPrice;
    uint public initialTime;
    uint tokenPrice;

    uint increasePerBlock;
    uint increasePerBlockDiv;

    bool public autoPrice;
    bool public isPaused;

    uint public minAcceptedETH;

    uint public tokenDecimals;
    uint public tokenMult;

    uint8 public stage;

    // Main counters

    uint public totalReceived;
    uint public totalSent;

    // Constructor function with main constants and variables 


 	function GXESwapper() {
		authorizedCaller = msg.sender;
		owner = msg.sender;

		collectorAddress = 0x24350803BFcE6E9D1f4baE0940E43af186A6D12C;
		tokenAdd = 0x106b419718298f91ca576728A670597fb2e0eE4e;
		tokenSpender = 0x24350803BFcE6E9D1f4baE0940E43af186A6D12C;

		whitelistAdd = 0xad56C554f32D51526475d541F5DeAabE1534854d;

		authorized[authorizedCaller] = true;

		minAcceptedETH = 0.05 ether;

		tokenDecimals = 10;
		tokenMult = 10 ** tokenDecimals;

		initialPrice = 10000 * tokenMult; // 10,000 tokens per ether (0,0001 eth/token)
		tokenPrice = initialPrice;
		autoPrice = false;

		initialTime = now;
		increasePerBlock = 159; // Percentage to add per each block respect original price, in cents
		increasePerBlockDiv = 1000000000; // According to specs: 1.59% x 10 ^ -5 (= 159 / 10 ^ 7) == 0.055 % per day

		stage = 1;
	}


	// Mapping to store swaps made and authorized callers

    mapping(address => uint) public receivedFrom;
    mapping(address => uint) public sentTo;
    mapping(address => bool) public authorized;

    // Event definitions

    event TokensSent(address _address , uint _received , uint _sent);

    // Modifier for authorized calls

    modifier isAuthorized() {
        require(authorized[msg.sender]);
        _;
    }

    modifier isNotPaused() {
    	require(!isPaused);
    	_;
    }

    // Function borrowed from ds-math.

    function mul(uint x, uint y) internal returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    // Falback function, invoked each time ethers are received

    function () payable { 
        makeSwapInternal();
    }


    // Ether swap, activated by the fallback function after receiving ethers

   function makeSwapInternal() private isNotPaused { // Main function, called internally when ethers are received

   	require(stage>0 && stage<3 && msg.value >= minAcceptedETH);

    Whitelist wl = Whitelist(whitelistAdd);

   	if (stage==1 || stage==2 ) require(wl.registered(msg.sender));

    ERC223 GXVCtoken = ERC223(tokenAdd);

    address _address = msg.sender;
    uint _value = msg.value;
    uint _price = getPrice();

	uint tokensToSend = _price * _value / 10 ** 18;

    receivedFrom[_address] += _value;
    totalReceived += _value;
    sentTo[_address] += tokensToSend;
    totalSent += tokensToSend;

    //Send tokens
    require(GXVCtoken.transferFrom(tokenSpender,_address,tokensToSend));
    // Log tokens sent for ethers;
    TokensSent(_address,_value,tokensToSend);
    // Send ethers to collector
    require(collectorAddress.send(_value));
    }

  

function getPrice() constant public returns(uint _price){
    if (autoPrice) {
        return calculatePrice(now);
    	} else {
    		return tokenPrice;
    		}
}

function getCurrentStage() public constant returns(uint8 _stage){
	return stage;
}

function calculatePrice(uint _when) constant public returns(uint _result){
	if (_when == 0) _when = now;
	// 25 are estimated of 25 seconds per block
	uint delay = (_when - initialTime) / 25;
	uint factor = delay * increasePerBlock;
	uint multip = initialPrice * factor;
	uint result = initialPrice - multip / increasePerBlockDiv;
	require (result<=initialPrice);
	return result;
 }


function changeToStage(uint8 _stage) isAuthorized returns(bool) {
	require(stage < _stage && _stage < 4);
	stage = _stage;
	return true;
}

function pause() public isAuthorized {
	isPaused = true;
}

function resume() public isAuthorized {
	isPaused = false;
}

function setManualPrice(uint _price) public isAuthorized {
    autoPrice = false;
    tokenPrice = _price;
}

function setAutoPrice() public isAuthorized {
    autoPrice = true;
}

function setInitialTime() public isAuthorized {
    initialTime = now;
}

function getNow() public constant returns(uint _now){
	return now;
}

function flushEthers() public isAuthorized { // Send ether to collector
  require( collectorAddress.send(this.balance) );
}

function changeMinAccEthers(uint _newMin) public isAuthorized {
  minAcceptedETH = _newMin;
}

function addAuthorized(address _address) public isAuthorized {
	authorized[_address] = true;

}

function removeAuthorized(address _address) public isAuthorized {
	require(_address != owner);
	authorized[_address] = false;
}

function changeOwner(address _address) public {
	require(msg.sender == owner);
	owner = _address;
}

// To manage ERC20 tokens in case of accidental sending to the contract

function sendTokens(address _address , uint256 _amount) isAuthorized returns (bool success) {
    ERC20Basic token = ERC20Basic( tokenAdd );
    require( token.transfer(_address , _amount ) );
    return true;
}


}