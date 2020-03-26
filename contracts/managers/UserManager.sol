pragma solidity ^0.5.0;

import "../roles/User.sol";

contract UserManager {
    address managerCenter;

    address[] usersList; //所有注册了个人信息的用户的个人地址列表
    mapping(address => address) public users; //用户个人地址到用户信息合约地址的映射

    //权限限制
    address masterManager; //只有MasterManager可以读取usersList

    ///////////权限////////////

    ////////////函数///////////

    /**
    @dev 创建个人信息合约
    @param name 真实姓名的hex
    */
    function newUser(bytes10 name) public {
        users[msg.sender] = address(new User(name, msg.sender));
        usersList.push(msg.sender);
    }

    /**
    @dev 销毁个人信息合约
    */
    function delUser() public {
        address blank;
        users[msg.sender] = blank;
        for (uint256 i = 0; i < usersList.length; i++) {
            if (usersList[i] == msg.sender) {
                usersList[i] = usersList[usersList.length - 1];
                usersList.pop();
                break;
            }
        }
    }

    /**
    @dev 检查是否存在用户的信息
    */
    function isUser(address addr) public view returns (bool) {
        for (uint256 i = 0; i < usersList.length; i++) {
            if (usersList[i] == addr) {
                return true;
            }
        }
        return false;
    }

    function setManagerCenter(address center) public {
        address blank;
        if (managerCenter == blank) {
            managerCenter = center;
        } else {
            require(msg.sender == managerCenter, "无权修改managerCenter的地址");
            managerCenter = center;
        }
    }
}
