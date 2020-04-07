pragma solidity ^0.5.0;

import "./User.sol";
import "../entities/Activity.sol";
import "../entities/Vote.sol";


contract Club {
    ////////社团信息/////////////
    bytes32 public name; //社团名称

    //////////////////创建/////////////////////////////

    constructor(bytes32 _name, address _presidium) public {
        name = _name;
        presidium = _presidium;
    }

    ////////////////社团人员管理/////////////

    //地址互不重叠，即部长列表中的成员不在成员列表中，其他同理
    address public presidium; //主席，存储个人地址
    address[] public ministers; //部长列表，存储个人地址
    address[] members; //成员列表，存储个人地址

    address[] applicants; //申请加入社团的成员列表
    mapping(address => string) applicantsMsg; //申请人的申请信息

    //成员发生变动，用于更新成员列表
    event memberChangeEvent();

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
            //触发事件,前端更新成员列表
            emit memberChangeEvent();
        } else {
            user.applyRefus();
        }

        //移除申请信息
        applicants[index] = applicants[applicants.length - 1];
        applicants.pop();
    }

    //成员退出社团, 不设审批
    function withdraw() public onlyMember(msg.sender) {
        for (uint256 i = 0; i < members.length; i++) {
            if (members[i] == msg.sender) {
                members[i] = members[members.length - 1];
                members.pop();

                emit memberChangeEvent();
            }
        }
    }

    //任命部长

    event ministerChangeEvent();

    function appointMinisters(address mini)
        public
        onlyPresidium
        onlyMember(mini)
    {
        //从成员列表移除
        for (uint256 i = 0; i < members.length; i++) {
            if (members[i] == mini) {
                members[i] = members[members.length - 1];
                members.pop();
            }
        }
        //加入部长列表
        ministers.push(mini);

        emit ministerChangeEvent();
    }

    //移除部长
    function dismisstMinisters(address mini)
        public
        onlyPresidium
        onlyMinister(mini)
    {
        //从部长列表移除
        for (uint256 i = 0; i < ministers.length; i++) {
            if (ministers[i] == mini) {
                ministers[i] = ministers[members.length - 1];
                ministers.pop();

                emit ministerChangeEvent();

                break;
            }
        }
        //加入成员列表
        members.push(mini);

        emit memberChangeEvent();
    }

    //部长辞职
    function selfDismiss() public onlyMinister(msg.sender) {
        //从部长列表移除
        for (uint256 i = 0; i < ministers.length; i++) {
            if (ministers[i] == msg.sender) {
                ministers[i] = ministers[members.length - 1];
                ministers.pop();

                emit ministerChangeEvent();

                break;
            }
        }
        //加入成员列表
        members.push(msg.sender);

        emit memberChangeEvent();
    }

    ////////////////通知///////////////////

    notification[] notifications; //社团通知
    struct notification {
        string title;
        string date; //yyyy-MM-dd-hh-mm-ss
        string info;
    }

    //发送通知
    event newMessageEvent(uint256 index);

    function message(
        string memory _title,
        string memory _date,
        string memory _info
    ) public onlyPresidium {
        notifications.push(
            notification({title: _title, date: _date, info: _info})
        );

        emit newMessageEvent(notifications.length - 1);
    }

    //社团所有人可查看
    function getNotification(uint256 index)
        public
        view
        onlyPart(msg.sender)
        returns (string memory title, string memory date, string memory info)
    {
        return (
            notifications[index].title,
            notifications[index].date,
            notifications[index].info
        );
    }

    //获取通知数量
    function getNotifiAmount()
        public
        view
        onlyPart(msg.sender)
        returns (uint256 amount)
    {
        return notifications.length;
    }

    ////////////////活动///////////////////

    address[] activities; //发起的活动

    event newActEvent(address addr);

    //创建活动
    function newActivity(
        string memory _name,
        string memory _date,
        string memory _locate,
        string memory _message
    ) public onlyPresidium {
        address addr = address(new Activity(_name, _date, _locate, _message));
        activities.push(addr);

        emit newActEvent(addr);
    }

    function changeActState(address _act, uint8 _state)
        public
        onlyMinister(msg.sender)
    {
        Activity act = Activity(_act);
        act.changeState(_state);
    }

    function changeActInfo(
        address _act,
        string memory _name,
        string memory _date,
        string memory _locate,
        string memory _message
    ) public onlyMinister(msg.sender) {
        Activity act = Activity(_act);
        act.changeInfo(_name, _date, _locate, _message);
    }

    //查询是否为社团成员(包括主席、部长和成员，仅限本社团发起的活动
    function isMember(address addr) public view returns (bool) {
        //检查是否是本社团活动
        bool flag = false;
        for (uint256 i = 0; i < activities.length; i++) {
            if (activities[i] == msg.sender) {
                flag = true;
            }
        }
        Activity act = Activity(msg.sender);
        address actAddr = act.owner();
        require(
            msg.sender == address(this) && actAddr == address(this),
            "活动不归本社团所有"
        );

        //检查
        bool memFlag = false;
        if (addr == presidium) {
            memFlag = true;
        }
        if (!memFlag) {
            for (uint256 i = 0; i < ministers.length; i++) {
                if (ministers[i] == addr) {
                    memFlag = true;
                    break;
                }
            }
        }

        if (!memFlag) {
            for (uint256 i = 0; i < members.length; i++) {
                if (members[i] == addr) {
                    memFlag = true;
                    break;
                }
            }
        }

        return memFlag;
    }

    ////////////////投票///////////////////

    address[] votes; //社团投票地址列表

    //新建投票
    event newVoteEvent(address vote);

    function addVote(string memory _name, bool open, address[] voter)
        public
        onlyPresidium
    {
        address addr = address(new Vote(_name, open, voter));
        votes.push(addr);

        emit newVoteEvent(addr);
    }

    //获取投票
    function getVote()
        public
        view
        onlyPart(msg.sender)
        returns (address[] _votes)
    {
        return votes;
    }

    //添加投票项
    function addVoteItem(address vote, string memory description)
        public
        onlyPresidium
    {
        Vote v = Vote(vote);

        v.addItem(description);
    }

    //开始投票
    event votingStartEvent(address vote);

    function startVote(address vote) public onlyPresidium {
        Vote v = Vote(vote);

        v.startVoting();

        emit votingStartEvent(vote);
    }

    //结束投票
    event votingEndEvetn(address vote);

    function endVote(address vote) public onlyPresidium {
        Vote v = Vote(vote);

        v.endVoting();

        emit votingEndEvent(vote);
    }

    /////////////////权限检查//////////////

    modifier onlyPresidium() {
        require(msg.sender == presidium, "只有主席有权操作");
        _;
    }

    modifier onlyMember(address addr) {
        bool flag = false;
        for (uint256 i = 0; i < members.length; i++) {
            if (members[i] == addr) {
                flag = true;
                break;
            }
        }
        require(flag, "不是社团普通成员");
        _;
    }

    //主席拥有部长的所有权限
    modifier onlyMinister(address addr) {
        bool flag = false;
        for (uint256 i = 0; i < ministers.length; i++) {
            if (ministers[i] == addr) {
                flag = true;
                break;
            }
        }
        require(flag || addr == presidium, "不是社团部长或主席");
        _;
    }

    //社团任意成员
    modifier onlyPart(address addr) {
        //是否主席
        bool flag = false;
        if (msg.sender == presidium) {
            flag = true;
        }
        //是否部长k
        if (!flag) {
            for (uint256 i = 0; i < ministers.length; i++) {
                if (ministers[i] == msg.sender) {
                    flag = true;
                    break;
                }
            }
        }
        //是否普通成员
        if (!flag) {
            for (uint256 i = 0; i < members.length; i++) {
                if (members[i] == msg.sender) {
                    flag = true;
                    break;
                }
            }
        }

        require(flag, "不是社团成员");
        _;
    }
}
