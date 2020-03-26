pragma solidity ^0.5.0;

import "./ManagerCenter.sol";
import "../roles/Club.sol";
import "../managers/UserManager.sol";
import "../roles/User.sol";

contract ClubManager {
    address managerCenter;

    address[] clubs; //社团列表

    clubApply[] clubApplies; //申请创建社团的列表
    struct clubApply {
        bytes32 name;
        address presidium;
        string message;
    }
    ///////////权限////////////

    modifier onlyMasterManager() {
        require(
            msg.sender == ManagerCenter(managerCenter).masterManager(),
            "不是MasterManager"
        );
        _;
    }

    ///////////函数////////////

    function newClub(bytes32 _name, address _presidium)
        internal
        returns (address mClub)
    {
        address addr = address(new Club(_name, _presidium));
        clubs.push(addr);
        return addr;
    }

    //申请建立社团
    function applyNewClub(
        bytes32 _name,
        address _presidium,
        string memory _message
    ) public onlyMasterManager {
        //获取用户管理合约的实例
        UserManager um = UserManager(
            ManagerCenter(managerCenter).userManager()
        );
        //首先检查主席是否已经注册个人信息
        require(um.isUser(_presidium), "主席必须注册个人信息合约");
        //然后检查是否授予临时权限
        User user = User(um.users(_presidium));
        require(user.tempAuth() == address(this), "主席必须授予临时权限");

        //记录申请
        clubApplies.push(
            clubApply({name: _name, presidium: _presidium, message: _message})
        );
    }

    //master获取社团申请总数
    function getAppliesAmount()
        public
        view
        onlyMasterManager
        returns (uint256)
    {
        return clubApplies.length;
    }

    //获取特定申请的详细信息
    function getApplyInfo(uint256 index)
        public
        view
        onlyMasterManager
        returns (bytes32 _name, address _presidium, string memory _message)
    {
        clubApply memory _apply = clubApplies[index];
        return (_apply.name, _apply.presidium, _apply.message);
    }

    //审核申请
    function reviewApply(uint256 index, bool pass, string memory time)
        public
        onlyMasterManager
    {
        if (pass == true) {
            //创建社团
            address addr = newClub(
                clubApplies[index].name,
                clubApplies[index].presidium
            );

            //将社团加入主席的社团列表中
            User user = User(clubApplies[index].presidium);
            user.addClub(addr);
            //通知主席
            user.newNotice("系统通知", address(this), time, "社团创建申请通过");

            //删除申请
            clubApplies[index] = clubApplies[clubApplies.length - 1];
            clubApplies.pop();
        } else {
            //通知主席团成员
            User user = User(clubApplies[index].presidium);
            user.newNotice(
                "系统通知",
                address(this),
                time,
                "您创建社团的请求没有通过"
            );
            //删除申请
            clubApplies[index] = clubApplies[clubApplies.length - 1];
            clubApplies.pop();
        }
    }

    function setManagerCenter(address center) public {
        address blank;
        if (managerCenter == blank) {
            managerCenter = center;
        } else {
            require(msg.sender == managerCenter, "无权修改managerCenter的地址");
            managerCenter = center;
        }
    }
}
