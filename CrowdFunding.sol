pragma solidity >=0.5.0;

contract CrowdFunding{
    mapping(address=>uint) public contributors;
    address public manager;
    uint public minimumContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOfContributors;
    
    struct Request{
        string description;
        address payable recipeint;
        uint value;
        bool completed;
        uint noOfVoter;
        mapping(address=>bool) voters;
    }
    mapping(uint=>Request) public requests;
    uint public numRequest;
    
    
    
    constructor(uint _target,uint _deadline){
        target = _target;
        deadline = block.timestamp + _deadline; // deadline in seconds(like 3600sec(1 hour))
        minimumContribution = 100 wei;
        manager = msg.sender;
    }
    
    function sendEth() public payable{
        require(block.timestamp < deadline , "Contract Deadline Passed.");
        require(msg.value >= minimumContribution,"This Contract Minimum Contribution is 100 wei.");
        require(raisedAmount < target ,"Already target amount fulfilled.");
        if(contributors[msg.sender]==0){
            noOfContributors ++;
        }
        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;
    }
    
    function getConrtactBalance() public view returns(uint) {
        return address(this).balance;
    }
    function refund() public {
        require(block.timestamp > deadline && raisedAmount<target,"Contract are running.");
        require(contributors[msg.sender] > 0,"You have not contribute in this contract.");
        address payable user = payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender] = 0;
    }
    
    modifier onlyManager(){
        require(msg.sender == manager,"You can't call this funtion becuase this fuction call only Manager.");
        _;
    }
    
    function createRequest(string memory _desc,address payable _recipeintAddress,uint _value) public onlyManager{
        Request storage newRequest =  requests[numRequest++];
        newRequest.description = _desc;
        newRequest.recipeint = _recipeintAddress;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.noOfVoter = 0;
         
    }
    
    function voteRequest(uint _requestNo) public{
        require(contributors[msg.sender]>0,"You must be contributor.");
        Request storage thisrequset = requests[_requestNo];
        require(thisrequset.voters[msg.sender]==false,"You have already voted");
        thisrequset.voters[msg.sender]=true;
        thisrequset.noOfVoter++;
        
    }

    function makePayment(uint _requestNo) public onlyManager{
        require(raisedAmount>=target);
        Request storage thisRequest = requests[_requestNo];
        require(thisRequest.completed==false,"The request has been completed.");
        require(thisRequest.noOfVoter > noOfContributors/2,"Majority dose not support this request.");
        thisRequest.recipeint.transfer(thisRequest.value);
        thisRequest.completed=true;

    }
}