pragma solidity ^0.5.0;

import "./MasterManager.sol";
import "./ClubManager.sol";
import "./UserManager.sol";

contract ManagerCenter {
    address public userManager;
    address public masterManager;
    address public clubManager;

    constructor(
        address _userManager,
        address _masterManager,
        address _clubManager
    ) public {
        userManager = _userManager;
        masterManager = _masterManager;
        clubManager = _clubManager;

        UserManager(userManager).setManagerCenter(address(this));
        MasterManager(masterManager).setManagerCenter(address(this));
        ClubManager(clubManager).setManagerCenter(address(this));
    }
}
