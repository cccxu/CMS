const UserManager = artifacts.require("UserManager");
const User = artifacts.require("User");

contract("UserManager", accounts => {
    it("建立并检索用户合约", () => {
        return UserManager.deployed()
            .then(instance => {
                var addr1 = accounts[0];
                instance.newUser(web3.utils.utf8ToHex("小明"), { from: addr1 });
                return instance.users.call(addr1);
            })
            .then(addr => {
                return User.at(addr);
            })
            .then(userInstance => {
                return userInstance.name.call();
            })
            .then(name => {
                //bytes10会使用0补全位数，而web3的转换函数不会，所以只能对比utf8值，而不能对比转换后的值
                assert.equal(web3.utils.hexToUtf8(name), "小明", "用户合约创建错误");
            })
    })

    it("修改并检索用户message", () => {
        return UserManager.deployed()
            .then(instance => {
                return instance.users.call(accounts[0]);
            })
            .then(addr => {
                return User.at(addr);
            })
            .then(instance => {
                instance.setUserInfo(true, 8618812087780,
                    1093368800, "xuhaodev@qq.com", web3.utils.utf8ToHex("中国河北衡水"),
                    [utf82Hex("中文"), utf82Hex("English")], [utf82Hex("唱"), utf82Hex("跳"), utf82Hex("rap")], { from: accounts[0] });
                return instance.getUserInfo.call({ from: accounts[0] });
            })
            .then(info=>{
                assert.equal(info.gender, true, "性别错误");
                assert.equal(info.phone, 8618812087780, "电话错误");
                assert.equal(info.qq, 1093368800, "QQ错误");
                assert.equal(info.email, "xuhaodev@qq.com", "email错误");
                assert.equal(web3.utils.hexToUtf8(info.location), "中国河北衡水", "地区错误");
                let language = ["中文", "English"];
                for(var i = 0; i < info.language.length; i++){
                    assert.equal(web3.utils.hexToUtf8(info.language[i]), language[i], "语言错误");
                }
                let hobby = ["唱", "跳", "rap"];
                for(var i = 0; i < info.hobby.length; i++){
                    assert.equal(web3.utils.hexToUtf8(info.hobby[i]), hobby[i], "喜好错误");
                }
            })
    })
})

function utf82Hex(str) {
    return web3.utils.utf8ToHex(str);
}

function hex2Utf8(hex) {
    return web3.utils.hex2Utf8(hex);
}