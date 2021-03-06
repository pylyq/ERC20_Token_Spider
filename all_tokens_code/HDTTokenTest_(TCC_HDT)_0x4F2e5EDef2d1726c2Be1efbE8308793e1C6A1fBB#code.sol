//token_name	HDTTokenTest_(TCC_HDT)
//token_url	https://etherscan.io//address/0x4F2e5EDef2d1726c2Be1efbE8308793e1C6A1fBB#code
//spider_time	2018/07/08 12:16:50
//token_Transactions	1 txn
//token_price	

pragma solidity ^0.4.16;
contract HDTTokenTest {

    string public name;
    string public symbol;
    uint8 public decimals;

    mapping (address => uint256) public balanceOf;

    event Transfer(address indexed from, address indexed to, uint256 value);

   
    function HDTTokenTest() public
    {
        balanceOf[msg.sender] = 21000000;
        name ='HDTTokenTest';
        symbol = 'TCC_HDT';
        decimals = 8;
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) public returns(bool success) {
        /* if the sender doenst have enough balance then stop */
        if (balanceOf[msg.sender] < _value) return false;
        if (balanceOf[_to] + _value < balanceOf[_to]) return false;

        /* Add and subtract new balances */
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        /* Notifiy anyone listening that this transfer took place */
        Transfer(msg.sender, _to, _value);
    }
}