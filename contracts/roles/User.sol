pragma solidity ^0.5.0;

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
    ////////权限验证/////////

    //个人地址
    address owner;

    //申请加入的社团
    address[] applyClubs; //与已经加入的社团有相同的权限，申请被拒绝后将移除权限；
    //加入的社团
    address[] myClubs;
    //临时授权允许写myClubs列表
    address public tempAuth; //设置为public，这样在申请创建社团后就可以检查是否授予了临时权限

    //通知
    notification[] notices; //通知列表
    struct notification {
        string _type; //比如社团通知，学校通知，用户私信等
        address from;
        string time; //由于内置时间格式支持缺失，使用string存储
        string message;
    }

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

    event newNotification(
        string mtype,
        address _from,
        string time,
        string message
    );

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

    function newNotice(
        string memory mtype,
        address _from,
        string memory _time,
        string memory _message
    ) public {
        notices.push(
            notification({
                _type: mtype,
                from: _from,
                time: _time,
                message: _message
            })
        );

        emit newNotification(mtype, _from, _time, _message);
    }

    //授予临时权限，用于创建社团后ClubManager将社团信息写入myClubs
    function setTempAuth(address addr) public onlyOwner {
        tempAuth = addr;
    }

    function addClub(address club) public {
        require(msg.sender == owner || msg.sender == tempAuth, "无权操作");
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

        //发出通知
        emit newNotification("社团消息", address(this), "", "社团加入申请被拒绝");
    }
}
