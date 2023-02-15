// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Betting is Ownable{
    // 컨트랙트에 있는 총  클레이튼의 양
    uint public totalMoney = 0; 
    // 베팅 가능 여부
    bool public limitBetting = false;

    // 베팅한 주소, 양, 어다에 베팅했는지
    struct Bet { 
        address addr;
        uint amount;
        string upOrDown;
    }
    
    Bet[] public bets;

    // 위 또는 아래에 베팅된 양 
    struct UpOrDown {
        string name;
        uint totalBet;
    }

    UpOrDown[] public upOrDowns;
    
    //베팅 여부
    mapping(address => bool) checkBet;
    
    //베팅할때 이벤트 발생
    event NewBetting (address addr,uint amount,string upOrDown);

    // 보상지급 결과 이벤트
    event Response(bool success, bytes data);
    
    // 초기 베팅 세팅
    constructor () {
        upOrDowns.push(UpOrDown("Up", 0));
        upOrDowns.push(UpOrDown("Down", 0));
    }


    function startBetting() public onlyOwner {
        require(limitBetting == false, "Already started");
        limitBetting = true;
    }

    function endBetting() public onlyOwner {
        require(limitBetting == true, "Already end");
        limitBetting = false;
    }

    // 베팅하는 함수
    function bet(string memory _upOrDown) public payable {
        require( keccak256(bytes(_upOrDown)) == keccak256(bytes("Up")) || keccak256(bytes(_upOrDown)) == keccak256(bytes("Down")), "Onle bet to Up or Down");
        require( checkBet[msg.sender] == false, "Only betting once.");
        require(msg.value >= 1 * 10^16,"Minimum betting amount is 0.01.");
        require(limitBetting == true, "wait for the next game");

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

    // betting된 금액 불러오기
    // up == 0 , dowm == 1
    function getTotalbet(uint _num) public view returns(uint) {
        return upOrDowns[_num].totalBet;
    }

    // 양쪽에 betting된 금액 불러오기
    function getEachBet() public view returns(uint, uint) {
        return (upOrDowns[0].totalBet,upOrDowns[1].totalBet);
    }

    // 결과 입력시 보상 분배
    function setResult(uint _num) public onlyOwner {
        uint award = 0;
        if (_num == 0) {
            for (uint i=0; i < bets.length; i++) {
                if (keccak256(bytes(bets[i].upOrDown)) == keccak256(bytes("Up"))){
                    award = (bets[i].amount * 9000 + bets[i].amount * (upOrDowns[1].totalBet * 9000 /(upOrDowns[0].totalBet))) / 10000;
                    (bool success, bytes memory data) = bets[i].addr.call{value: award}("");
                    bets[i].amount = 0;
                    emit Response(success, data);
                    require(success, "Failed to send Ether");
                }
                checkBet[bets[i].addr] = false;
            }
        } else {
            for (uint i=0; i < bets.length; i++) {
                if (keccak256(bytes(bets[i].upOrDown)) == keccak256(bytes("Down"))){
                    award = (bets[i].amount * 9000 + bets[i].amount * (upOrDowns[0].totalBet * 9000 /(upOrDowns[1].totalBet))) / 10000;
                    (bool success, bytes memory data) = bets[i].addr.call{value: award}("");
                    bets[i].amount = 0;
                    emit Response(success, data);
                    require(success, "Failed to send Ether");
                }
                checkBet[bets[i].addr] = false;
            }

        }

        totalMoney = 0;
        upOrDowns[0].totalBet = 0;
        upOrDowns[1].totalBet = 0;
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

}

