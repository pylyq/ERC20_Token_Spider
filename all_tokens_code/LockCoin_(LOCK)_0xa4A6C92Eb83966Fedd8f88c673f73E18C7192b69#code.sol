//token_name	LockCoin_(LOCK)
//token_url	https://etherscan.io//address/0xa4A6C92Eb83966Fedd8f88c673f73E18C7192b69#code
//spider_time	2018/07/08 12:52:56
//token_Transactions	14 txns
//token_price	

contract Token {
    
	/* Public variables of the token */
	string public name;
	string public symbol;
	uint8 public decimals;
	uint256 public totalSupply;
    
	/* This creates an array with all balances */
	mapping (address => uint256) public balanceOf;

	/* This generates a public event on the blockchain that will notify clients */
	event Transfer(address indexed from, address indexed to, uint256 value);

	function Token() {
	    totalSupply = 10*(10**8)*(10**18);
		balanceOf[msg.sender] = 10*(10**8)*(10**18);              // Give the creator all initial tokens
		name = "LockCoin";                                   // Set the name for display purposes
		symbol = "LOCK";                               // Set the symbol for display purposes
		decimals = 18;                            // Amount of decimals for display purposes
	}

	function transfer(address _to, uint256 _value) {
	/* Check if sender has balance and for overflows */
	if (balanceOf[msg.sender] < _value || balanceOf[_to] + _value < balanceOf[_to])
		revert();
	/* Add and subtract new balances */
	balanceOf[msg.sender] -= _value;
	balanceOf[_to] += _value;
	/* Notifiy anyone listening that this transfer took place */
	Transfer(msg.sender, _to, _value);
	}

	/* This unnamed function is called whenever someone tries to send ether to it */
	function () {
	revert();     // Prevents accidental sending of ether
	}
}