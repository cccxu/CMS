pragma solidity ^0.5.0;

contract Master {
    ////公开信息////////
    bytes32 public name; //真实姓名
    uint64 public phone;
    string public email;

    ////权限信息///////
    address owner; //拥有者

    modifier onlyOwner() {
        require(msg.sender == owner, "不是合约拥有者");
        _;
    }

    ////////函数////////

    constructor(
        bytes32 _name,
        uint64 _phone,
        string memory _email,
        address _owner
    ) public {
        name = _name;
        phone = _phone;
        email = _email;
        owmer = _owner;
    }

    function setInfo(bytes32 _name, uint64 _phone, string memory _email)
        public
        onlyOwner
    {
        name = _name;
        phone = _phone;
        email = _email;
    }
}
