// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract Lottery is ReentrancyGuard, Ownable {
    uint256 public lotteryPrize = 10000000000000000000;
    IERC20 public token;

    mapping(uint16 => bool) public purchased;
    mapping(uint16 => address) public tickets;

    constructor(address _owner, address _token) {
        transferOwnership(_owner);
        token = IERC20(_token);
    }

    /**
     * @notice Functions that allows to buy lottery numbers with tokens.
     * @param _ticket Lottery number to be purchased.
     */
    function buyLottery(uint16 _ticket) public nonReentrant {
        require(_ticket > 0 && _ticket <= 10000, "Ticket number should be more than 1 and less than 10000.");
        require(!purchased[_ticket], "Ticket not available.");
        uint256 _userBalance = token.balanceOf(msg.sender);
        require(_userBalance >= lotteryPrize, "Insufficient Balance.");

        token.transferFrom(msg.sender, address(this), lotteryPrize);

        purchased[_ticket] = true;
        tickets[_ticket] = msg.sender;
    }
}