// const User = artifacts.require("User");
const UserManager = artifacts.require("UserManager");
const ClubManager = artifacts.require("ClubManager");
const MasterManager = artifacts.require("MasterManager");
const ManagerCenter = artifacts.require("ManagerCenter");

module.exports = function (deployer) {
  deployer.deploy(MasterManager);
  deployer.deploy(ClubManager);
  deployer.deploy(UserManager);
};