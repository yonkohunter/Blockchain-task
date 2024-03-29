
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;




error NotOwner();

contract FundMe {
    

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    address public owner;
    address public new_owner;

    // Could we make this constant?  /* hint: no! We should make it immutable! */
    
    uint256 public constant MINIMUM_ETH = 1;
    
    constructor() {
        owner = msg.sender;
    }

    function fund() public payable {
        require(msg.value >= MINIMUM_ETH, "You need to spend more ETH!");
        
	bool isNewFunder = true;              //checking whether the sender's address is already in the funders array aor not
    	for (uint256 i = 0; i < funders.length; i++) {
        	if (funders[i] == msg.sender) {
            		isNewFunder = false;
            		break;
        	}
    	}

        if (isNewFunder) {
        	addressToAmountFunded[msg.sender] += msg.value;
        	funders.push(msg.sender);
    	}
    }
    
    
    
    modifier onlyOwner {
       if (msg.sender != owner) revert NotOwner();
        _;
    }

     function NEW_Ownership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid address");
        new_owner = newOwner;
    }
    function accept_ownership() public {
        require(msg.sender == new_owner, "Not authorized to accept ownership");
        owner = new_owner;
        new_owner = address(0);
    }
    function withdraw() public onlyOwner {
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        // // transfer
        // payable(msg.sender).transfer(address(this).balance);
        // // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");
        // call
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }
    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

    
}
