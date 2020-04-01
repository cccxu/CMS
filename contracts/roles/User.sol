pragma solidity ^0.5.0;

import "./Activity.sol";


contract User {
    /////用户个人信息//////
    //基本信息
    bytes10 public name; //真实姓名，通过bytes10限制长度
    string public imgUrl; //头像url
    string public message; //个人留言
    //附加信息
    bool gender; //0 女 1 男
    uint64 phone; //电话号码，避免维护困难，使用整数位存储
    uint64 qq; //QQ
    string email; //邮件地址
    bytes32 location; //使用明文保存地址信息，避免地区代码带来的转换问题
    bytes32[] language; //使用的语言
    bytes32[] hobby; //个人爱好

    //个人地址
    address owner;

    //申请加入的社团
    address[] applyClubs; //与已经加入的社团有相同的权限，申请被拒绝后将移除权限；
    //加入的社团
    address[] myClubs;
    //临时授权允许写myClubs列表
    address[] public tempAuth; //设置为public，这样在申请创建社团后就可以检查是否授予了临时权限

    //私信
    bool pmFlag; //true: 所有人可以发送私信
    address[] pmList; //pmFlag为false时仅列表内的人可以发送私信
    pMessage[] pMessages; //私信列表
    struct pMessage {
        address from;
        string time; //由于内置时间格式支持缺失，使用string存储
        string message;
    }

    //参加的活动
    activity[] activities; //活动记录
    struct activity {
        address actAddr; //活动合约地址
        uint8 applyState; //申请状态（0 等待审核/1 已加入/2 被拒绝）
        uint8 actState; //活动状态（0 未开始/1 进行中/2 已结束/3 已取消）
    }

    ///////////权限////////////////
    modifier onlyOwner {
        require(msg.sender == owner, "不是合约拥有者");
        _;
    }

    modifier onlyMyClubs {
        bool flag = false;
        for (uint256 i = 0; i < myClubs.length; i++) {
            if (myClubs[i] == msg.sender) {
                flag = true;
                break;
            }
        }
        if (!flag) {
            for (uint256 i = 0; i < applyClubs.length; i++) {
                if (applyClubs[i] == msg.sender) {
                    flag = true;
                    break;
                }
            }
        }
        require(flag, "社团无授权");
        _;
    }

    modifier clubsOrSelf {
        bool flag = false;
        for (uint256 i = 0; i < myClubs.length; i++) {
            if (myClubs[i] == msg.sender) {
                flag = true;
                break;
            }
        }
        if (!flag) {
            for (uint256 i = 0; i < applyClubs.length; i++) {
                if (applyClubs[i] == msg.sender) {
                    flag = true;
                    break;
                }
            }
        }
        require(flag || msg.sender == owner, "不是已加入的社团或合约拥有者");
        _;
    }
    ////////事件////////////

    event applyPassEvent(address club); //新加入社团通过

    event newPMessage(address _from, string time, string message);

    event clubRefus(address addr); //社团申请被拒绝

    ////////方法/////////////

    /**
    构造函数，只传入姓名，其余信息单独设置
    */
    constructor(bytes10 _name, address _owner) public {
        name = _name;
        owner = _owner;
    }

    function setImgUrl(string memory _imgUrl) public onlyOwner {
        imgUrl = _imgUrl;
    }

    function setMessage(string memory _message) public onlyOwner {
        message = _message;
    }

    function setUserInfo(
        bool _gender,
        uint64 _phone,
        uint64 _qq,
        string memory _email,
        bytes32 _location,
        bytes32[] memory _language,
        bytes32[] memory _hobby
    ) public onlyOwner {
        gender = _gender;
        phone = _phone;
        qq = _qq;
        email = _email;
        location = _location;
        language = _language;
        hobby = _hobby;
    }

    /**
    需要通过授权的社团通过合约调用，
    调用对应的interface方法，不要直接调用本方法（权限检定不会通过）
    */
    function getUserInfo()
        public
        view
        clubsOrSelf
        returns (
            bool _gender,
            uint64 _phone,
            uint64 _qq,
            string memory _email,
            bytes32 _location,
            bytes32[] memory _language,
            bytes32[] memory _hobby
        )
    {
        return (gender, phone, qq, email, location, language, hobby);
    }

    function sendPMessage(
        address _from,
        string memory _time,
        string memory _message
    ) public {
        pMessages.push(pMessage({from: _from, time: _time, message: _message}));

        emit newPMessage(_from, _time, _message);
    }

    //授予临时权限，用于创建社团后ClubManager将社团信息写入myClubs
    function setTempAuth(address addr) public onlyOwner {
        tempAuth.push(addr);
    }

    function addClub(address club) public {
        bool flag = false;
        for (uint256 i = 0; i < tempAuth.length - 1; i++) {
            if (tempAuth[i] == msg.sender) {
                flag = true;
                break;
            }
        }
        require(msg.sender == owner || flag, "无权添加社团");
        //避免重复添加
        for (uint256 i = 0; i < myClubs.length; i++) {
            if (myClubs[i] == club) {
                return;
            }
        }
        myClubs.push(club);
    }

    function addApplyClub(address club) public onlyOwner {
        for (uint256 i = 0; i < applyClubs.length; i++) {
            if (applyClubs[i] == club) {
                return;
            }
        }
        //将社团加入applyClubs
        applyClubs.push(club);
    }

    function applyPass() public {
        //权限检查
        bool flag = false;
        uint256 index;
        for (uint256 i = 0; i < applyClubs.length; i++) {
            if (applyClubs[i] == msg.sender) {
                flag = true;
                index = i;
                break;
            }
        }
        require(flag, "没有申请加入社团");
        //将社团加入myClubs
        myClubs.push(msg.sender);
        //从申请列表移除
        applyClubs[index] = applyClubs[applyClubs.length - 1];
        applyClubs.pop();

        //从临时权限列表移除
        for (uint256 i = 0; i < tempAuth.length - 1; i++) {
            if (tempAuth[i] == msg.sender) {
                tempAuth[i] = tempAuth[tempAuth.length - 1];
                tempAuth.pop();
            }
        }

        emit applyPassEvent(msg.sender);
    }

    function applyRefus() public {
        //权限检查
        bool flag = false;
        uint256 index;
        for (uint256 i = 0; i < applyClubs.length; i++) {
            if (applyClubs[i] == msg.sender) {
                flag = true;
                index = i;
                break;
            }
        }
        require(flag, "没有申请加入社团");
        //将社团移除申请列表
        //从申请列表移除
        applyClubs[index] = applyClubs[applyClubs.length - 1];
        applyClubs.pop();

        //从临时权限列表移除
        for (uint256 i = 0; i < tempAuth.length - 1; i++) {
            if (tempAuth[i] == msg.sender) {
                tempAuth[i] = tempAuth[tempAuth.length - 1];
                tempAuth.pop();
            }
        }

        //发出通知
        emit clubRefus(address(this));
    }

    //添加活动
    function addAct(address addr) public onlyOwner {
        Activity mactivity = Activity(addr);
        uint8 state = mactivity.state();
        if (state == 2 || state == 3) {
            require(false, "活动已结束/已取消");
        }
        activities.push(
            activity({actAddr: addr, applyState: 0, actState: state})
        );
        //提交申请
        mactivity.join(owner);
    }

    //活动申请通过
    function actPass() public {
        //在列表中找到对应的活动
        for (uint256 i = 0; i < activities.length; i++) {
            if (activities[i].actAddr == msg.sender) {
                activities[i].applyState = 1;
                break;
            }
        }
    }

    //活动申请已提交
    function actApply() public {
        //在列表中找到对应的活动
        for (uint256 i = 0; i < activities.length; i++) {
            if (activities[i].actAddr == msg.sender) {
                activities[i].applyState = 0;
                break;
            }
        }
    }

    //活动申请被拒绝
    function actRefus() public {
        //在列表中找到对应的活动
        for (uint256 i = 0; i < activities.length; i++) {
            if (activities[i].actAddr == msg.sender) {
                activities[i].applyState = 2;
                break;
            }
        }
    }

    //TODO: 私信权限控制
    //TODO: 发送私信
    //TODO: 查看私信
}
