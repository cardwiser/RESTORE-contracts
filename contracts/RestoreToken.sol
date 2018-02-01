import "./ERC20.sol";
pragma solidity ^0.4.17;
contract RestoreToken is ERC20 {
    string public constant name = "RESTORE";
    string public constant symbol = "RESTORE";
    uint8 public constant decimals = 4;
    uint public totalSupply = 0;
    address public owner;
    address[] public minters;
    
    mapping(address => uint) public balances;
    mapping(address => mapping (address => uint)) public allowed;
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    modifier onlyMinters() {
        bool isMinter = false;
        for (uint i = 0; i < minters.length; i++) {
            if(msg.sender == minters[i]) { isMinter = true; }
        }
        require(isMinter);
        _;
    }
 
    function RestoreToken(uint _initialSupply) public {
        totalSupply = _initialSupply;
        owner = msg.sender;
        minters.push(owner);
        balances[owner] = totalSupply;
        Minted(0x0, owner, totalSupply);
    }
    
    function mintToken(address _to, uint _amount) public onlyMinters {
        balances[_to] += _amount;
        totalSupply += _amount;
        Minted(msg.sender, _to, _amount);
    }
    
    function addMinter(address _minter) public onlyOwner {
        require(_minter != 0x0);
        bool minterExists = false;
        for (uint i = 0; i < minters.length; i++) {
            if(_minter == minters[i]) {
                minterExists = true;
            }
        }
        if(!minterExists) {
            minters.push(_minter);
        }
    }
    
    function removeMinter(address _minter) public onlyOwner {
        require(_minter != 0x0);
        uint minterIndex;
        bool minterFound = false;
        for (uint i = 0; i < minters.length; i++) {
            if(_minter == minters[i]) {
                minterIndex = i;
                minterFound = true;
            }
        }
        require(minterFound);
        minters[minterIndex] = minters[minters.length-1];
        delete minters[minters.length-1];
    }
    
    function totalSupply() public constant returns (uint supply) {
        return totalSupply;
    }
 
    function balanceOf(address _owner) public constant returns (uint balance) {
        return balances[_owner];
    }
    
    function transfer(address _to, uint _amount) public returns (bool success) {
        if (balances[msg.sender] >= _amount && _amount > 0 && balances[_to] + _amount > balances[_to]) {
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(msg.sender, _to, _amount);
            return true;
        } else {
            return false;
        }
    }
    
    function transferFrom(
        address _from,
        address _to,
        uint _amount
    ) public returns(bool success) {
        if (balances[_from] >= _amount
            && allowed[_from][msg.sender] >= _amount
            && _amount > 0
            && balances[_to] + _amount > balances[_to]) {
            balances[_from] -= _amount;
            allowed[_from][msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }
    
    function approve(address _spender, uint _amount) public returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        return true;
    }
    
    function allowance(address _owner, address _spender) public constant returns (uint remaining) {
        return allowed[_owner][_spender];
    }

}