// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

// TODO: Cambiar direcciones, keyHash y fee de VRFConsumerBase.
contract Lottery is ReentrancyGuard, Ownable, VRFConsumerBase {
    uint256 public lotteryPrize = 10000000000000000000;
    IERC20 public token;
    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 public randomResult;

    mapping(uint16 => address) public tickets;

    constructor(address _owner, address _token) VRFConsumerBase(0xa555fC018435bef5A13C6c6870a9d4C11DEC329C, 0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06) {
        transferOwnership(_owner);
        token = IERC20(_token);
        keyHash = 0xcaf3c3727e033261d383b315559476f48034c13b18f8cafed4d871abe5049186;
        fee = 0.1 * 10 ** 18; // 0.1 LINK (Varies by network)
    }

    /** 
     * @notice Requests randomness.
     */
    function getRandomNumber() public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee);
    }

    /**
     * @notice Callback function used by VRF Coordinator.
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = randomness % 10000 + 1;
    }

    /**
     * @notice Functions that allows to buy lottery numbers with tokens.
     * @param _ticket Lottery number to be purchased.
     */
    function buyLottery(uint16 _ticket) public nonReentrant {
        require(_ticket > 0 && _ticket <= 10000, "Ticket number should be more than 1 and less than 10000.");
        require(tickets[_ticket] == address(0), "Ticket not available.");
        uint256 _userBalance = token.balanceOf(msg.sender);
        require(_userBalance >= lotteryPrize, "Insufficient Balance.");

        token.transferFrom(msg.sender, address(this), lotteryPrize);

        tickets[_ticket] = msg.sender;
    }
}