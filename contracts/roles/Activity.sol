pragma solidity ^0.5.0;

import "./Club.sol";
import "./User.sol";


contract Activity {
    address public owner; //所属社团
    string public name; //活动名称
    string public date; //活动时间
    string public locate; //活动地点
    string public message; //额外信息

    uint8 public state; //0 未开始，1 进行中，2 已结束，3 已取消

    address[] members; //活动人员名单，个人地址
    address[] applicants; //社团外人员申请列表

    notification[] notifications; //社团通知
    struct notification {
        string title;
        string date; //yyyy-MM-dd-hh-mm-ss
        string info;
    }
    //////////////事件/////////////

    event applicantsChange();

    event membersChange();

    event stateChange();

    event infoChange();

    //发送活动通知
    event newMessage(uint256 index);

    ///////////权限//////////////

    //活动所属社团成员检查
    // modifier onlyMember(address addr) {
    //     Club club = Club(owner);
    //     require(club.isMember(addr),"");
    // }

    //仅活动成员可以
    modifier onlyMember(address addr) {
        bool flag = false;
        for (uint256 i = 0; i < members.length; i++) {
            if (members[i] == addr) {
                flag = true;
            }
        }
        require(flag, "不是活动成员，请先加入活动再进行操作");
        _;
    }

    modifier onlyApplicant(address addr) {
        bool flag = false;
        for (uint256 i = 0; i < applicants.length; i++) {
            if (applicants[i] == addr) {
                flag = true;
            }
        }
        require(flag, "该成员没有提交申请");
        _;
    }

    ////////////////////////////

    constructor(
        string memory _name,
        string memory _date,
        string memory _locate,
        string memory _message
    ) public {
        owner = msg.sender;
        name = _name;
        date = _date;
        locate = _locate;
        message = _message;
    }

    //查询人员名单
    function getMember()
        public
        view
        onlyMember(msg.sender)
        returns (address[] memory)
    {
        return members;
    }

    //加入活动，活动所属社团成员可以直接加入，其余人员需等待社团部长/主席审核后通过
    function join(address addr) public {
        Club club = Club(owner);
        if (club.isMember(addr)) {
            //社团成员
            //加入活动成员列表
            members.push(addr);
            //调用user的方法，返回成功信息（先调用申请提交，然后直接调用申请通过）
            User user = User(addr);
            user.actApply();
            user.actPass();

            emit membersChange();
        } else {
            //非社团成员
            //加入申请列表
            applicants.push(addr);
            //调用user的方法，返回状态
            User user = User(addr);
            user.actApply();

            emit applicantsChange();
        }
    }

    //获取申请列表
    function getApplies() public view returns (address[] memory) {
        require(msg.sender == owner, "您没有权限查询申请列表");
        return applicants;
    }

    //通过申请
    function pass(address addr) public onlyApplicant(addr) {
        require(msg.sender == owner, "您没有权限进行此操作");
        for (uint256 i = 0; i < applicants.length; i++) {
            if (applicants[i] == addr) {
                User user = User(addr);
                user.actPass();

                //从申请列表移除
                applicants[i] = applicants[applicants.length - 1];
                applicants.pop();
                //加入成员列表
                members.push(addr);

                emit membersChange();
                emit applicantsChange();
            }
        }
    }

    //更改活动状态
    function changeState(uint8 _state) public {
        require(msg.sender == owner, "没有权限修改活动状态");
        state = _state;

        emit stateChange();
    }

    //修改活动信息
    function changeInfo(
        string memory _name,
        string memory _date,
        string memory _locate,
        string memory _message
    ) public {
        //只有社团可以进行修改
        require(msg.sender == owner, "无权修改活动信息");
        name = _name;
        date = _date;
        locate = _locate;
        message = _message;

        emit infoChange();
    }

    //发送通知
    function addMessage(
        string memory _title,
        string memory _date,
        string memory _info
    ) public {
        require(msg.sender == owner, "无权发送通知");
        notifications.push(
            notification({title: _title, date: _date, info: _info})
        );

        emit newMessage(notifications.length - 1);
    }

    function getNotification(uint256 index)
        public
        view
        onlyMember(msg.sender)
        returns (string memory title, string memory date, string memory info)
    {
        return (
            notifications[index].title,
            notifications[index].date,
            notifications[index].info
        );
    }

    function getNotifiAmount()
        public
        view
        onlyMember(msg.sender)
        returns (uint256 amount)
    {
        return notifications.length;
    }
}
