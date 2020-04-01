const MasterManager = artifacts.require("MasterManager");
const Master = artifacts.require("Master");

const Utils = require("./Utils.js")
/**
 * accounts[0] : admin
 * accounts[1] : master
 * accounts[2] : user, presidium
 * accounts[3] : user
 */

contract("MasterManager", accounts => {
    it("建立并检索导师合约", () => {
        return MasterManager.deployed()
            .then(instance => {
                instance.newMaster(Utils.utf82Hex("王泡泡"), 13241233232, "paopaowang@cqu.edu.cn", accounts[1], { from: accounts[0] });
                return instance;
            })
            .then(instance => {
                return instance.masters(accounts[1]);
            })
            .then(addr => {
                return Master.at(addr);
            })
            .then(master => {
                return master.name.call();
            })
            .then(name => {
                assert.equal(Utils.hex2Utf8(name), "王泡泡");
            });
    });
})