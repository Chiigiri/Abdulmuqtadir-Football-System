// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract AbdulmuqtadirFootballSystem{
    address public owner;
    using Strings for uint256;
    using Strings for address;

    struct Player {
        bool isRegistered;
        uint256 goals;
        uint256 yellowCards;
        bool redCarded;
    }
    constructor() {
     owner=msg.sender;
    }

    mapping(address => Player) public players;
    address[] public playerAddresses;
    address public referee;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    modifier onlyReferee() {
        require(msg.sender == referee, "Only referee can perform this action");
        _;
    }

    event PlayerRegistered(address indexed player);
    event GoalScored(address indexed player, uint256 goals);
    event YellowCardGiven(address indexed player, uint256 yellowCards);
    event RedCardGiven(address indexed player);

    function setReferee(address _referee) external onlyOwner {
        referee = _referee;
    }

    function registerPlayer(address player) external onlyReferee {
        require(!players[player].isRegistered, "Player already registered");
        players[player] = Player(true, 0, 0, false);
        playerAddresses.push(player);
        emit PlayerRegistered(player);
    }

    function scoreGoal(address player) external onlyReferee {
        require(players[player].isRegistered, "Player not registered");
        require(!players[player].redCarded, "Player is red carded");

        players[player].goals++;
        emit GoalScored(player, players[player].goals);
    }

    function giveYellowCard(address player) external onlyReferee {
        require(players[player].isRegistered, "Player not registered");
        require(!players[player].redCarded, "Player is red carded");

        players[player].yellowCards++;
        emit YellowCardGiven(player, players[player].yellowCards);

        if (players[player].yellowCards >= 2) {
            players[player].redCarded = true;
            emit RedCardGiven(player);
        }
    }

    function determineManOfTheMatch() public view onlyReferee returns (address) {
        require(playerAddresses.length > 0, "No players registered");

        address bestPlayer = address(0);
        uint256 maxGoals = 0;
        uint256 minYellowCards = type(uint256).max;
        uint256 playerCount = playerAddresses.length;

        for (uint i = 0; i < playerCount; i++) {
            address currentPlayer = playerAddresses[i];
            uint256 currentGoals = players[currentPlayer].goals;
            uint256 currentYellowCards = players[currentPlayer].yellowCards;

            if (currentGoals > maxGoals || (currentGoals == maxGoals && currentYellowCards < minYellowCards)) {
                bestPlayer = currentPlayer;
                maxGoals = currentGoals;
                minYellowCards = currentYellowCards;
            }
        }
        return bestPlayer;
    }

    function getMatchReport() public view onlyReferee returns (string memory) {
        address bestPlayer = determineManOfTheMatch();
        return string(abi.encodePacked("Man of the Match: ", bestPlayer.toHexString()));
    }
}
