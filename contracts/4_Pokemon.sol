// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

struct PokemonItem {string name; uint256 level;}
struct PokemonItemDTO {uint256 id; string name; uint256 level;}


contract Pokemon {

    uint256 private sessionId;
    uint256 private lastPokemonAdded;

    address public  author;
    bool public sessionOpen;
    uint256[] public pockemonsId;

    event SessionClosed(uint256 indexed sessionId, uint256 timestamp);
    event NewPokemon(string indexed name, uint256 indexed level);

    mapping(uint256 => PokemonItem) pokemonList;
    mapping(address => bool) isRegistered;

    modifier onlyAuthor() {
        require(msg.sender == author, "You're not the author");
        _;
    }

    constructor(address _author) {
        author = _author;
    }

    function openSession() external onlyAuthor {
        sessionId++;
        require(sessionOpen == false, "Session Already Opened");
        sessionOpen = true;
    }

    function closeSession() external onlyAuthor {
        require(sessionOpen == true, "Session Already Closed");
        sessionOpen = false;
        emit SessionClosed(sessionId, block.timestamp);
    }

    function addPokemon (string memory name, uint256 level) 
    external onlyAuthor {
        lastPokemonAdded++;
        pokemonList[lastPokemonAdded].name  = name;
        pokemonList[lastPokemonAdded].level = level;
        pockemonsId.push(lastPokemonAdded);
        emit NewPokemon(name, level);
    }

    function levelUpPockemon(uint256 pockemonId, uint256 newLevel)
    external {
        require(sessionOpen, "session closed");
        pokemonList[pockemonId].level = newLevel;
    }

    function getPokemons() external view returns (PokemonItemDTO[] memory) {
        
        uint256 pockemonCount = pockemonsId.length;
        PokemonItemDTO[] memory allPokemon = new PokemonItemDTO[](pockemonCount);

        for (uint256 i = 0; i < pockemonCount; i++) {
            uint256 pokId = pockemonsId[i];
            allPokemon[i].id = pokId ;
            allPokemon[i].name = pokemonList[pokId].name;
            allPokemon[i].level = pokemonList[pokId].level;
        }

        return allPokemon;
    }
}