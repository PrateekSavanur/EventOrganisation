// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

contract EventContract {
    struct Event {
        address organiser;
        string name;
        uint date;
        uint price;
        uint ticketCount;
        uint ticketRemain;
    }

    mapping(uint => Event) public events;
    mapping(address => mapping(uint => uint)) public tickets;
    uint public nextId;

    function createEvent(string memory name, uint date, uint price, uint ticketCount) external {
        require(date > block.timestamp, "You can set an event for the future only");
        require(ticketCount > 0, "At least 1 ticket is required");
        events[nextId] = Event(msg.sender, name, date, price, ticketCount, ticketCount);
        nextId++;
    }

    function buyTicket(uint id, uint quantity) external payable {
        require(events[id].date != 0, "Event does not exist");
        require(block.timestamp < events[id].date, "Event has already finished");

        Event storage _event = events[id];

        require(msg.value == (_event.price * quantity), "Ether amount is not enough");
        require(_event.ticketRemain >= quantity, "Not enough tickets available");

        _event.ticketRemain -= quantity;
        tickets[msg.sender][id] += quantity;
    }

    function transferTicket(uint id, uint quantity, address to) external {
        require(events[id].date != 0, "Event does not exist");
        require(block.timestamp < events[id].date, "Event has already finished");

        require(tickets[msg.sender][id] >= quantity, "Not enough tickets available");
        tickets[msg.sender][id] -= quantity;
        tickets[to][id] += quantity;
    }
}
