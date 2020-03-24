pragma solidity ^0.5.0;

contract Club{
    ////////社团信息/////////////
    bytes32 public name;  //社团名称

    address[] public presidiums;  //主席团成员，存储个人地址
    address[] public ministers;  //部长列表，存储个人地址
    address[] members;  //成员列表，存储个人地址

    //////////函数/////////////

    constructor (bytes32 _name, address[] memory _presidiums) public {
        name = _name;
        predisium = _presidium;
    }
}