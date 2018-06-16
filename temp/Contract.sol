pragma solidity ^0.4.17;

contract EventFactory {
    address[] public deployedEvents;

    function createEvent(uint seats, string description) public {
        address newEvent = new Event(seats, msg.sender, description);
        deployedEvents.push(newEvent);
    }

    function getDeployedEvents() public view returns(address []){
        return deployedEvents;
    }
}
contract Event{
    struct OwnershipTransfer {
        address recipient;
        uint value;
    }
    address public organizer;
    uint public seatsAvailable;
    string public eventDescription;
    mapping(uint => address) public seatOwnership;
    mapping(uint => OwnershipTransfer) public transferRequests;


    function Event(uint seats, address creater, string description) public {
        eventDescription = description;
        organizer = creater;
        seatsAvailable = seats;
        for(uint i = 0; i < seatsAvailable;  i++){
            seatOwnership[i] = organizer;
        }
    }

    function getEventDescription() public view returns(string){
        return eventDescription;
    }

    function getSeatsAvailable() public view returns(uint){
        return seatsAvailable;
    }

    function getSeatOwnership(uint seatIndex) public view returns(address){
        return seatOwnership[seatIndex];
    }

    function initiateTransfer(uint seatIndex, address newOwner, uint value) public {
        require(msg.sender == seatOwnership[seatIndex]);
        OwnershipTransfer memory newTransfer = OwnershipTransfer({
            recipient: newOwner,
            value: value
        });
        transferRequests[seatIndex] = newTransfer;
    }

    function completeTransfer(uint seatIndex) public payable {
        require(msg.sender == transferRequests[seatIndex].recipient);
        require(msg.value >= transferRequests[seatIndex].value);
        seatOwnership[seatIndex].transfer(msg.value);
        seatOwnership[seatIndex] = msg.sender;
        OwnershipTransfer memory emptyTransfer = OwnershipTransfer({
            recipient: 0,
            value: 0
        });
        transferRequests[seatIndex] = emptyTransfer;
    }

    function getTransferRequestRecipient(uint seatIndex) public view returns(address){
        return transferRequests[seatIndex].recipient;
    }

    function getTransferRequestValue(uint seatIndex) public view returns(uint){
        return transferRequests[seatIndex].value;
    }

    function transferOwnershipWithoutEther(uint seatIndex, address newOwner) public {
        require(msg.sender == seatOwnership[seatIndex]);
        seatOwnership[seatIndex] = newOwner;
    }
}
