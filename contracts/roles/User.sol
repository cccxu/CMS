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

    //加入的社团
    address[] myClubs;

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
        require(flag, "不是已加入的社团");
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
        require(flag || msg.sender == owner, "不是已加入的社团或合约拥有者");
        _;
    }

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
            bool gender,
            uint64 phone,
            uint64 qq,
            string memory email,
            bytes32 location,
            bytes32[] memory language,
            bytes32[] memory hobby
        )
    {
        return (gender, phone, qq, email, location, language, hobby);
    }
}
