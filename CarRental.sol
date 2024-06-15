// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CarRental {
    address public owner;
    uint public rentalFeePerDay;
    uint public securityDeposit;
    address public renter;
    uint public rentalStartTime;
    uint public rentalEndTime;
    bool public isRented;

    event CarRented(address indexed renter, uint rentalStartTime, uint rentalEndTime);
    event CarReturned(address indexed renter, uint returnTime);
    event SecurityDepositRefunded(address indexed renter, uint amount);

    constructor(uint _rentalFeePerDay, uint _securityDeposit) {
        owner = msg.sender;
        rentalFeePerDay = _rentalFeePerDay;
        securityDeposit = _securityDeposit;
        isRented = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier onlyRenter() {
        require(msg.sender == renter, "Only the renter can call this function");
        _;
    }

    modifier notRented() {
        require(!isRented, "Car is already rented");
        _;
    }

    function rentCar(uint _rentalDays) public payable notRented {
        require(msg.value >= securityDeposit + (_rentalDays * rentalFeePerDay), "Insufficient payment");

        renter = msg.sender;
        rentalStartTime = block.timestamp;
        rentalEndTime = rentalStartTime + (_rentalDays * 1 days);
        isRented = true;

        emit CarRented(renter, rentalStartTime, rentalEndTime);
    }

    function returnCar() public onlyRenter {
        require(block.timestamp <= rentalEndTime, "Rental period has expired");

        isRented = false;
        uint rentalDuration = block.timestamp - rentalStartTime;
        uint rentalCost = (rentalDuration / 1 days) * rentalFeePerDay;
        uint refundAmount = securityDeposit + (msg.value - rentalCost);

        payable(renter).transfer(refundAmount);

        emit CarReturned(renter, block.timestamp);
        emit SecurityDepositRefunded(renter, refundAmount);
    }

    function withdrawFunds() public onlyOwner {
        require(!isRented, "Car is currently rented");
        payable(owner).transfer(address(this).balance);
    }

    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }
}
