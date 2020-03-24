pragma solidity ^0.5.0;

import "../roles/Master";

contract MasterManager {
    mapping(address => address) public masters; //导师个人地址到信息合约的映射

    //创建导师信息合约
    function newMaster(bytes32 _name, uint64 _phone, string memory _email)
        public
    {
        masters[msg.sender] = address(
            new Master(_name, _phone, _email, msg.sender)
        );
    }

    //销毁导师信息合约
    function delMaster() public {
        address blank;
        masters[msg.sender] = blank;
    }
}
