//token_name	
//token_url	https://etherscan.io//address/0x452ee11eb4ed8e709c510659f31c4942c14ff608#code
//spider_time	2018/07/08 11:51:28
//token_Transactions	36 txns
//token_price	

pragma solidity ^0.4.23;

contract EthMash {

    address public owner;
    mapping (address => uint) public balances;

    address public leader;

    event Log(address challenger, address defender, bool success);

    constructor() public {
        owner = msg.sender;
        leader = owner;
    }

    function publicGetBalance(address player) view public returns (uint) {
        return balances[player];
    }

    function publicGetState() view public returns (address) {
        return leader;
    }

    function userWithdraw() public {
        require(balances[msg.sender] > 0);
        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;
        msg.sender.transfer(amount);
    }

    function userChallenge() public payable {
        require(msg.value == 100 finney);
        
        uint random = (uint(blockhash(block.number - 1)) + uint(leader) + uint(msg.sender));
        if (random % 2 == 1) {
            emit Log(msg.sender, leader, true);
            balances[msg.sender] += 100 finney;
            leader = msg.sender;
        } else {
            emit Log(msg.sender, leader, false);
            balances[leader] += 95 finney;
            balances[owner] += 5 finney;
        }
    }
}