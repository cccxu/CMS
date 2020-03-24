pragma solidity ^0.5.0;

import "../roles/User.sol";

contract UserManager {
    mapping(address=>address) public users;  //用户个人地址到用户信息合约地址的映射

    /**
    @dev 创建个人信息合约
    @param name 真实姓名的hex
    */
    function newUser(bytes10 name) public {
        users[msg.sender] = address(new User(name, msg.sender));
    }

    /**
    @dev 销毁个人信息合约
    */
    function delUser() public {
        address blank;
        users[msg.sender] = blank;
    }
}