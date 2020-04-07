pragma solidity ^0.5.0;

import "../entities/Activity.sol";


contract User {
    //个人地址
    address owner;

    ////////创建////////////////////////////////////

    /**
    构造函数，只传入姓名，其余信息单独设置
    */
    constructor(bytes10 _name, address _owner) public {
        name = _name;
        owner = _owner;
    }

    //////////////////////////////////////////////
    ///////////个人信息////////////////////////////
    /////////////////////////////////////////////

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

    /////////////////////////////////////////////////////
    ///////////授权//////////////////////////////////////
    ////////////////////////////////////////////////////

    //私信相关授权

    bool plFlag; //true: 所有人可以发送私信
    address[] plList; //pmFlag为false时仅列表内的人可以发送私信

    //控制是否所有人可以发送私信
    function modifyPLFlag(bool _plFlag) public onlyOwner {
        plFlag = _plFlag;
    }

    //向授权列表添加
    function addToPLList(address addr) public onlyOwner {
        //检查是否已经在授权列表中
        for (uint256 i = 0; i < plList.length; i++) {
            if (plList[i] == addr) {
                return;
            }
        }
        plList.push(addr);
    }

    //从授权列表移除
    function removeFromPLList(address addr) public onlyOwner {
        for (uint256 i = 0; i < plList.length; i++) {
            if (plList[i] == addr) {
                plList[i] = plList[plList.length - 1];
                plList.pop();
                break;
            }
        }
    }

    //其他授权

    //临时授权允许写myClubs列表
    address[] tempAuth; //设置为public，这样在申请创建社团后就可以检查是否授予了临时权限

    //授予临时权限，用于创建社团后ClubManager将社团信息写入myClubs
    function setTempAuth(address addr) public onlyOwner {
        tempAuth.push(addr);
    }

    function checkAuth() public view returns (bool) {
        for (uint256 i = 0; i < tempAuth.length; i++) {
            if (tempAuth[i] == msg.sender) {
                return true;
            }
        }

        return false;
    }

    ///////////////////////////////////////////////////
    ///////////社团////////////////////////////////////
    //////////////////////////////////////////////////

    //申请加入的社团
    address[] applyClubs; //与已经加入的社团有相同的权限，申请被拒绝后将移除权限；
    //加入的社团
    address[] myClubs;

    event newClubEvent(address club);

    function addClub(address club) public {
        bool flag = false;
        for (uint256 i = 0; i < tempAuth.length - 1; i++) {
            if (tempAuth[i] == msg.sender) {
                flag = true;
                //从列表移除
                tempAuth[i] = tempAuth[tempAuth.length - 1];
                tempAuth.pop();
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

        emit newClubEvent(club);
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

    event applyPassEvent(address club); //新加入社团通过

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

    //申请被拒绝
    event clubRefusEvent(address addr); //社团申请被拒绝

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
        emit clubRefusEvent(address(this));
    }

    ///////////////////////////////////////////////////////
    ///////////活动///////////////////////////////////////////
    ////////////////////////////////////////////////////
    //参加的活动
    activity[] activities; //活动记录
    struct activity {
        address actAddr; //活动合约地址
        uint8 applyState; //申请状态（0 等待审核/1 已加入/2 被拒绝）
        uint8 actState; //活动状态（0 未开始/1 进行中/2 已结束/3 已取消）
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

    ////////////////////////////////////////////////
    ///////////私信/////////////////////////////////////
    //////////////////////////////////////////////////

    //私信

    pLetter[] pLetters; //私信列表
    struct pLetter {
        address from;
        string title;
        string time; //由于内置时间格式支持缺失，使用string存储
        string message;
    }

    //发送私信
    event incomingMessage(string title, address from);

    function sendPrivateLetter(
        string memory _time,
        string memory _title,
        string memory _message
    ) public {
        if (!plFlag) {
            bool flag = false;
            for (uint256 i = 0; i < plList.length; i++) {
                if (plList[i] == msg.sender) {
                    flag = true;
                }
            }
            require(flag, "没有私信权限");
        }
        pLetters.push(
            pLetter({
                from: msg.sender,
                title: _title,
                time: _time,
                message: _message
            })
        );

        emit incomingMessage(_title, msg.sender);
    }

    //查看私信
    function getPrivateLetter(uint256 index)
        public
        view
        onlyOwner
        returns (
            address from,
            string memory title,
            string memory time,
            string memory _message
        )
    {
        return (
            pLetters[index].from,
            pLetters[index].title,
            pLetters[index].time,
            pLetters[index].message
        );
    }

    function getPrivateLetterAmount()
        public
        view
        onlyOwner
        returns (uint256 amount)
    {
        return pLetters.length;
    }

    //////////////////////////////////////////////////
    ///////////权限///////////////////////////////////
    ////////////////////////////////////////////////

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
}
