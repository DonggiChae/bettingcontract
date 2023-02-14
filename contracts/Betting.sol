// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Betting is Ownable{
    uint public totalMoney = 0; 
    struct Bet { 
        address addr;
        uint amount;
        string upOrDown;
    }
    struct UpOrDown {
        string name;
        uint totalBet;
    }
    Bet[] public bets;
    UpOrDown[] public upOrDowns;
    mapping(address => bool) checkBet;

    event NewBetting (address addr,uint amount,string upOrDown);
    
    constructor () {
        upOrDowns.push(UpOrDown("Up", 0));
        upOrDowns.push(UpOrDown("Down", 0));
    }
    
    receive() external payable {}

    function bet(string memory _upOrDown) public payable {
        require( checkBet[msg.sender] == false, "Onle betting once.");
        require(msg.value >= 0.01 ether,"Minimum betting amount is 0.01.");


        bets.push(Bet(msg.sender, msg.value, _upOrDown));
        checkBet[msg.sender] = true;

        if (keccak256(bytes(_upOrDown)) == keccak256(bytes("Up"))) {
            upOrDowns[0].totalBet += msg.value;
        }

        if (keccak256(bytes(_upOrDown)) == keccak256(bytes("Down"))) {
            upOrDowns[1].totalBet += msg.value;
        }

        totalMoney += msg.value;

        emit NewBetting(msg.sender, msg.value, _upOrDown);
    }

    // up == 0 , dowm == 1
    function getTotalbet(uint _num) public view returns(uint) {
        return upOrDowns[_num].totalBet;
    }

    function getEachBet() public view returns(uint, uint) {
        return (upOrDowns[0].totalBet,upOrDowns[1].totalBet);
    }

    function getAward() public {

    }

    function setResult(uint _num) public onlyOwner {
        uint award = 0;
        if (_num == 0) {
            for (uint i=0; i < bets.length; i++) {
                if (keccak256(bytes(bets[i].upOrDown)) == keccak256(bytes("Up"))){
                    award = bets[i].amount * (10000 + (upOrDowns[1].totalBet * 10000 /upOrDowns[0].totalBet /10000 ));
                    (bool sent, bytes memory data) = bets[i].addr.call{value: award}("");
                    require(sent, "Failed to send Ether");
                }
                checkBet[bets[i].addr] = false;
            }
        } else {
            for (uint i=0; i < bets.length; i++) {
                if (keccak256(bytes(bets[i].upOrDown)) == keccak256(bytes("Down"))){
                    award = bets[i].amount * (10000 + (upOrDowns[0].totalBet * 10000 /upOrDowns[1].totalBet /10000 ));
                    (bool sent, bytes memory data) = bets[i].addr.call{value: award}("");
                    require(sent, "Failed to send Ether");
                }
                checkBet[bets[i].addr] = false;
            }

        }

        totalMoney = 0;
        upOrDowns[0].totalBet = 0;
        upOrDowns[1].totalBet = 0;
    }

}


// starttime 받아오기 or endtime
// end 트리거
