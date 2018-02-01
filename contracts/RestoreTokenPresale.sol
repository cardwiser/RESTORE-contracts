import "./RestoreToken.sol";
pragma solidity ^0.4.17;
contract RestoreTokenPresale {
    address owner;
    mapping(address => uint) public contributions;
    address[] public contributors;
    address beneficiary;
    uint public totalContributions;
    bool public saleEnded = false;
    RestoreToken public tokenReward;
    uint public constant saleCap = 300000000000000;
    uint public tokensSold = 0;
    uint public etherCostOfEachToken = 0.000000003333333 * 1 ether;
    
    event FundTransfer(address backer, uint amount, bool isContribution);
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    function RestoreTokenPresale(address _tokenAddress, address _beneficiary) public {
        owner = msg.sender;
        beneficiary = _beneficiary;
        tokenReward = RestoreToken(_tokenAddress);
    }
    
    function() public payable {
        require(!saleEnded);
        uint tokenValue = (msg.value / etherCostOfEachToken);
        require(tokenValue > 0);
        if(tokensSold + tokenValue < saleCap) {
            /// record the contribution and release tokens
            contributions[msg.sender] += msg.value;
            totalContributions += msg.value;
            addContributor(msg.sender);
            tokensSold += tokenValue;
            tokenReward.transfer(msg.sender, tokenValue);
        } else {
            /// calculate how many tokens are available to sell
            uint tokensToSell = saleCap - tokensSold;
            
            /// calculate the ether cost of the remaining tokens
            uint costForTokens = tokensToSell * etherCostOfEachToken;
            
            /// return the contributor's ether that can't be used
            uint returnAmt = msg.value - costForTokens;
            msg.sender.transfer(returnAmt);
            
            /// record the contribution and release tokens
            contributions[msg.sender] += costForTokens;
            totalContributions += costForTokens;
            addContributor(msg.sender);
            tokenReward.transfer(msg.sender, tokensToSell);
            tokensSold += tokensToSell;
            
            /// end the sale
            saleEnded = true;
        }
    }
    
    function addContributor(address _contributor) private {
        bool _exists = false;
        for (uint i = 0; i < contributors.length; i++) {
            if(_contributor == contributors[i]) {
                _exists = true;
            }
        }
        if(!_exists) {
            contributors.push(_contributor);
        }
    }
    
    function getNumberOfContributors() public constant returns(uint){
        return contributors.length;
    }
    
    function endSale() public onlyOwner {
        if((saleCap - tokensSold) > 0) {
            tokenReward.transfer(beneficiary, saleCap - tokensSold);
        }
        saleEnded = true;
    }
    
    function withdraw() public onlyOwner {
        address contractAddress = this;
        beneficiary.transfer(contractAddress.balance);
    }
    
}