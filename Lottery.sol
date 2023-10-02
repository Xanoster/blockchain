// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

contract Lottery{

address payable[] public players ;
address public manager;
address payable public winner;

constructor(){
    manager=msg.sender;
}

function participate() public payable {
    require(msg.value==1 ether,"Deposit 1 ETH");
    players.push(payable(msg.sender));
}
function getBalance() public view returns(uint) {
    require(manager==msg.sender,"You are not manager");
    return address(this).balance;
}
function random() public view returns(uint){
    return uint(keccak256(abi.encodePacked(block.difficulty,block.timestamp,players.length)));
}
function pickWinner() public {
    require(manager==msg.sender);
    require(players.length>=1);
    uint r=random();

    uint index=r%players.length;
    winner=players[index];
    winner.transfer(getBalance());
    players=new address payable[](0);
}
}
