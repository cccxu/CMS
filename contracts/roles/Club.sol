pragma solidity ^0.5.0;

import "./User.sol";

contract Club {
    ////////社团信息/////////////
    bytes32 public name; //社团名称

    address public presidium; //主席，存储个人地址
    address[] public ministers; //部长列表，存储个人地址
    address[] members; //成员列表，存储个人地址

    address[] applicants; //申请加入社团的列表
    mapping(address => string) applicantsMsg; //申请人的申请信息
    /////////权限检查//////////

    modifier onlyPresidium() {
        require(msg.sender == presidium, "只有主席有权操作");
        _;
    }
    //////////////////////////

    //////////事件/////////////

    event newMember(address _newMember);

    //////////////////////////
    //////////函数/////////////

    constructor(bytes32 _name, address _presidium) public {
        name = _name;
        presidium = _presidium;
    }

    function applyForJoin(string memory message) public {
        //检查是否允许访问个人信息
        User user = User(msg.sender);
        user.getUserInfo(); //没有权限事务将回滚，申请自动失败
        //加入申请列表
        //防止重复添加
        for (uint256 i = 0; i < applicants.length; i++) {
            if (applicants[i] == msg.sender) {
                return;
            }
        }
        applicants.push(msg.sender);
        applicantsMsg[msg.sender] = message;
    }

    //获取申请的总数
    function getApplyAmount() public view onlyPresidium returns (uint256) {
        return applicants.length;
    }

    //获取特定的申请
    function getApply(uint256 index)
        public
        view
        onlyPresidium
        returns (string memory)
    {
        return applicantsMsg[applicants[index]];
    }

    //审核特定的申请
    function reviewApply(uint256 index, bool pass) public onlyPresidium {
        User user = User(applicants[index]);
        if (pass) {
            //调用user的applyPass
            user.applyPass();
            //触发事件
            emit newMember(applicants[index]);
        } else {
            user.applyRefus();
        }

        //移除申请信息
        applicants[index] = applicants[applicants.length - 1];
        applicants.pop();
    }
}
