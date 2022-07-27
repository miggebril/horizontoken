pragma solidity ^0.8.9;
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract HorizonToken is ERC20, AccessControl {

    constructor(address to, uint256 amount) ERC20("HorizonToken", "HO") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        mint(to, amount);
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}