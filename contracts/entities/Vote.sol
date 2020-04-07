pragma solidity ^0.5.0;


contract Vote {
    string public name; //投票名称
    address public owner; //所属社团地址

    bool open; //公开投票，false: 只有voter可以投票，true：所有人可以投票

    address[] voter; //投票人员
    address[] voted; //已投票人员

    struct item {
        string description; //描述
        uint256 yes; //赞成
        uint256 no; //不赞成
        uint256 abstain; //弃权
    }
    item[] items; //投票项列表

    uint8 state; //投票状态：0 未开始 1 进行中 2 已结束

    //创建投票项
    constructor(string memory _name, bool _open,address[] memory _voter) public {
        owner = msg.sender;
        name = _name;
        voter = _voter;
        open = _open;
        state = 0;
    }

    modifier onlyVoter(address addr) {
        if (!open) {
            bool flag = false;
            for (uint256 i = 0; i < voter.length; i++) {
                if (voter[i] == addr) {
                    flag = true;
                    break;
                }
            }
            require(flag, "不是授权的投票人员");
        }

        _;
    }

    modifier onlyVoted(address addr) {
        bool flag = false;
        for (uint256 i = 0; i < voted.length; i++) {
            if (voted[i] == addr) {
                flag = true;
                break;
            }
        }
        require(flag, "投票后才可访问");
        _;
    }

    //////////////////////////////////////////////////
    ////////////////////管理投票//////////////////////////
    //////////////////////////////////////////////////

    //添加投票项
    function addItem(string memory _description) public {
        require(msg.sender == owner, "无权限");

        items.push(
            item({description: _description, yes: 0, no: 0, abstain: 0})
        );
    }

    //开始投票
    function startVoting() public {
        require(msg.sender == owner, "无权限");

        state = 1;
    }

    //结束投票
    function endVoting() public {
        require(msg.sender == owner, "无权限");

        state = 2;
    }
    //////////////////////////////////////////////////
    ////////////////////投票和获取结果//////////////////////////
    //////////////////////////////////////////////////

    //获取投票项
    function getItemsCount()
        public
        view
        onlyVoter(msg.sender)
        returns (uint256 count)
    {
        return items.length;
    }

    function getItem(uint256 index)
        public
        view
        onlyVoter(msg.sender)
        returns (string memory desc)
    {
        return items[index].description;
    }

    //获取投票结果
    function getItemResult(uint256 index)
        public
        view
        onlyVoted(msg.sender)
        returns (string memory desc, uint256 y, uint256 n, uint256 abs)
    {
        //投票结束才可查看结果
        require(state == 2, "请投票结束后再查看结果");
        return (
            items[index].description,
            items[index].yes,
            items[index].no,
            items[index].abstain
        );
    }

    function voteForItem(uint256 index, uint256 result)
        public
        onlyVoter(msg.sender)
    {
        //避免重复投票
        bool flag = false;
        for (uint256 i = 0; i < voted.length; i++) {
            if (voted[i] == msg.sender) {
                flag = true;
                break;
            }
        }
        require(!flag, "不要重复投票");

        if (result == 0) {
            //不赞成
            items[index].no++;
        } else if (result == 1) {
            //赞成
            items[index].yes++;
        } else {
            items[index].abstain++;
        }

        voted.push(msg.sender);
    }

    //////////////////////////////////////////////////
    ////////////////////////////通知////////////////////////
    //////////////////////////////////////////////////

    struct notification {
        string title;
        string date; //yyyy-MM-dd-hh-mm-ss
        string info;
    }
    notification[] notifications; //社团通知

    //发送通知
    event newNotification();

    function addNotifi(
        string memory _title,
        string memory _date,
        string memory _info
    ) public {
        require(msg.sender == owner, "无权限发送通知");

        notifications.push(
            notification({title: _title, date: _date, info: _info})
        );

        emit newNotification();
    }

    //读取通知
    function getNotifiCount()
        public
        view
        onlyVoter(msg.sender)
        returns (uint256 count)
    {
        return notifications.length;
    }

    function getNotifi(uint256 index)
        public
        view
        onlyVoter(msg.sender)
        returns (string memory _title, string memory _date, string memory _info)
    {
        return (
            notifications[index].title,
            notifications[index].date,
            notifications[index].info
        );
    }
}
