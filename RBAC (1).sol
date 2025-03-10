// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title AbdulmuqtadirFootballSystem
 * @dev A smart contract for tracking football player stats, including goals and cards.
 */
contract AbdulmuqtadirFootballSystem {
    address public owner; // Contract owner
    using Strings for uint256;
    using Strings for address;

    struct Player {
        bool isRegistered; // Indicates if player is registered
        uint256 goals; // Number of goals scored
        uint256 yellowCards; // Number of yellow cards received
        bool redCarded; // Indicates if player has received a red card
    }

    constructor() {
        owner = msg.sender; // Assign contract deployer as owner
    }

    mapping(address => Player) public players; // Mapping of player addresses to Player struct
    address[] public playerAddresses; // List of registered players
    address public referee; // Address of the referee

    // Modifiers to restrict access
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    modifier onlyReferee() {
        require(msg.sender == referee, "Only referee can perform this action");
        _;
    }

    // Events for logging actions
    event PlayerRegistered(address indexed player);
    event GoalScored(address indexed player, uint256 goals);
    event YellowCardGiven(address indexed player, uint256 yellowCards);
    event RedCardGiven(address indexed player);

    /**
     * @dev Assigns the referee role to an address (only owner can do this).
     * @param _referee Address of the referee
     */
    function setReferee(address _referee) external onlyOwner {
        referee = _referee;
    }

    /**
     * @dev Registers a player in the system (only referee can do this).
     * @param player Address of the player to register
     */
    function registerPlayer(address player) external onlyReferee {
        require(!players[player].isRegistered, "Player already registered");
        players[player] = Player(true, 0, 0, false);
        playerAddresses.push(player);
        emit PlayerRegistered(player);
    }

    /**
     * @dev Records a goal for a player (only referee can do this).
     * @param player Address of the player scoring a goal
     */
    function scoreGoal(address player) external onlyReferee {
        require(players[player].isRegistered, "Player not registered");
        require(!players[player].redCarded, "Player is red carded");

        players[player].goals++;
        emit GoalScored(player, players[player].goals);
    }

    /**
     * @dev Gives a yellow card to a player. If a player gets 2 yellow cards, they receive a red card.
     * @param player Address of the player receiving a yellow card
     */
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

    /**
     * @dev Determines the Man of the Match based on goals and fewer yellow cards.
     * @return Address of the best player
     */
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

    /**
     * @dev Generates a match report including the Man of the Match.
     * @return String containing the Man of the Match
     */
    function getMatchReport() public view onlyReferee returns (string memory) {
        address bestPlayer = determineManOfTheMatch();
        return string(abi.encodePacked("Man of the Match: ", bestPlayer.toHexString()));
    }
}
