//A distributed wallet is a bank like structure, to submit and withdraw money with multiple acounts//

pragma solidity ^0.6.0;

contract wallet{
    address public owner;
    
    constructor() public{
        owner = msg.sender;
    }
    
    bool public paused;
    
    struct payment{
        uint amt;
        uint timestamp;
        
    }
    
    struct balance{
        uint totalBalance;
        uint numPay;
        mapping(uint => payment) payments;
    }
    
    modifier whilenotpaused{
        require(paused == false, "SC is paused");
        _;
    }
    mapping(address => balance) public balanceRecord;
    
    event sentMoney(address indexed add1, uint amt1);
    event recMoney(address indexed add2, uint amt2);
    
    function sendmoney() public payable whilenotpaused{
        balanceRecord[msg.sender].totalBalance += msg.value ;
        balanceRecord[msg.sender].numPay += 1;
        payment memory pay = payment(msg.value, now);
        balanceRecord[msg.sender].payments[balanceRecord[msg.sender].numPay] = pay;
        emit sentMoney(msg.sender, msg.value);
    }
    
    function getbal() whilenotpaused public view onlyOwner returns(uint){
        return balanceRecord[msg.sender].totalBalance;
    }
    
    function converttoken(uint aiw) public pure returns(uint) {
        return aiw / 1 ether;
    } 
    
    modifier onlyOwner() {
        require(owner == msg.sender, "You're not the owner of the wallet");
        _;
    }
    
    function withdraw(uint amount) public whilenotpaused onlyOwner{
        require(balanceRecord[msg.sender].totalBalance >= amount, "Your accont foes not have enough funds");
        balanceRecord[msg.sender].totalBalance -= amount;
        balanceRecord[msg.sender].numPay += 1;
        msg.sender.transfer(amount);
        emit recMoney(msg.sender, amount);
        
    }
    
    function change(bool ch) public onlyOwner{
        paused = ch;
    }
    
    function destroySC(address payable destination) public onlyOwner{
        selfdestruct(destination);
    }
    
}
