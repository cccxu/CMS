pragma solidity ^0.5.0;

import "../roles/Master.sol";
import "./UserManager.sol";
import "./ClubManager.sol";

import "../roles/User.sol";

contract MasterManager {
    address managerCenter;

    address admin; //管理员，管理导师的创建等

    address[] mastersList; //导师列表
    mapping(address => address) public masters; //导师个人地址到信息合约的映射

    ////////权限验证////////////

    modifier onlyAdmin() {
        require(msg.sender == admin, "只有管理员有权进行操作！");
        _;
    }

    modifier onlyMaster() {
        for (uint256 i = 0; i < mastersList.length; i++) {
            if (mastersList[i] == msg.sender) {
                _;
                return;
            }
        }
        require(false, "只有导师有权操作！");
    }

    //////////////////////////

    constructor() public {
        admin = msg.sender;
    }

    //创建导师信息合约
    function newMaster(bytes32 _name, uint64 _phone, string memory _email, address _owner)
        public
        onlyAdmin
    {
        address addr = address(new Master(_name, _phone, _email, _owner));
        masters[_owner] = addr;
        mastersList.push(_owner);
    }

    //销毁导师信息合约并移除导师
    function delMaster() public {
        address blank;
        masters[msg.sender] = blank;
        for (uint256 i = 0; i < mastersList.length; i++) {
            if (mastersList[i] == msg.sender) {
                mastersList[i] = mastersList[mastersList.length - 1];
                mastersList.pop();
                break;
            }
        }
    }

    //更改管理员
    function setAdmin(address _admin) public onlyAdmin {
        admin = _admin;
    }

    function setManagerCenter(address center) public {
        address blank;
        if(managerCenter==blank){
            managerCenter = center;
        } else {
            require(msg.sender == managerCenter, "无权修改managerCenter的地址");
            managerCenter = center;
        }
    }
}
