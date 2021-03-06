// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

// TODO: Cambiar direcciones, keyHash y fee de VRFConsumerBase.
contract SmallLottery is ReentrancyGuard, VRFConsumerBase {
    address public owner;
    uint256 public lotteryPrize = 10000000000000000000;
    uint16 public lotteryNumbers = 999;
    IERC20 public token;
    bytes32 internal keyHash;
    uint256 internal fee;
    uint16 public winningTicket;
    bool private pickingWinner;
    uint256 public game = 1;

    mapping(uint256 => mapping(uint16 => address)) public games;

    constructor(address _owner, address _token) VRFConsumerBase(0xa555fC018435bef5A13C6c6870a9d4C11DEC329C, 0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06) {
        owner = _owner;
        token = IERC20(_token);
        keyHash = 0xcaf3c3727e033261d383b315559476f48034c13b18f8cafed4d871abe5049186;
        fee = 0.1 * 10 ** 18; // 0.1 LINK (Varies by network)
    }

    /**
     * @notice Calculate the percentage of a number.
     * @param x Number.
     * @param y Percentage of number.
     * @param scale Division.
     */
    function mulScale (uint x, uint y, uint128 scale) internal pure returns (uint) {
        uint a = x / scale;
        uint b = x % scale;
        uint c = y / scale;
        uint d = y % scale;

        return a * c * scale + a * d + b * c + b * d / scale;
    }

    /** 
     * @notice Requests randomness.
     */
    function getRandomNumber() public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        require(msg.sender == owner, "Only owners can call this function.");
        pickingWinner = true;
        return requestRandomness(keyHash, fee);
    }

    /**
     * @notice Callback function used by VRF Coordinator.
     */
    function fulfillRandomness(bytes32, uint256 randomness) internal override {
        winningTicket = uint16((randomness % 10000) + 1);
        selectWinner();
    }

    /**
     * @notice Functions that allows to buy lottery numbers with tokens.
     * @param _ticket Lottery number to be purchased.
     */
    function buyLottery(uint16 _ticket) public nonReentrant {
        require(!pickingWinner, "You can't buy a ticket now, we are picking a winner.");
        require(_ticket > 0 && _ticket <= lotteryNumbers, "Ticket number should be more than 1 and equal or less than 999.");
        require(games[game][_ticket] == address(0), "Ticket not available.");
        uint256 _userBalance = token.balanceOf(msg.sender);
        require(_userBalance >= lotteryPrize, "Insufficient Balance.");

        token.transferFrom(msg.sender, address(this), lotteryPrize);

        games[game][_ticket] = msg.sender;
    }

    /**
     * @notice Function that selects a winner and sends the prize.
     */
    function selectWinner() private {
        address _winner = games[game][winningTicket];
        uint256 _prizePool = token.balanceOf(address(this));

        if(_winner != address(0)) {
            uint256 _fee = mulScale(_prizePool, 1200, 10000); // 1200 basis points = 12%.
            uint256 _userTokens = _prizePool - _fee;

            token.transfer(owner, _fee);
            token.transfer(_winner, _userTokens);
        } else {
            token.transfer(owner, _prizePool);
        }
        
        pickingWinner = false;
        game++;
    }

    /**
     * @notice Function that allows the owner to withdraw LINK balance.
     */
    function withdrawLINK() public {
        require(msg.sender == owner, "Only owners can call this function.");
        uint256 _contractBalance = LINK.balanceOf(address(this));
        LINK.transfer(owner, _contractBalance);
    }
}