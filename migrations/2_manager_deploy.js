// const User = artifacts.require("User");
const UserManager = artifacts.require("UserManager");
const ClubManager = artifacts.require("ClubManager");
const MasterManager = artifacts.require("MasterManager");

const Club = artifacts.require("Club");

module.exports = function (deployer) {
  // deployer.deploy(MasterManager);
  // deployer.deploy(ClubManager);
  // deployer.deploy(UserManager);
  console.log(web3.eth.accounts[0]);
  deployer.deploy(Club, web3.utils.utf8ToHex("测试社团"), '0x2dFDB2d527b4857B7B1C387e9A26e5D10b23a486');
};