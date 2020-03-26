// const User = artifacts.require("User");
const UserManager = artifacts.require("UserManager");
const ClubManager = artifacts.require("ClubManager");
const MasterManager = artifacts.require("MasterManager");
const ManagerCenter = artifacts.require("ManagerCenter");
module.exports = function (deployer) {
  deployer.deploy(MasterManager)
  .then(() => {
    deployer.deploy(ClubManager)
      .then(() => {
      deployer.deploy(UserManager)
      .then(() => {
        deployer.deploy(ManagerCenter(
          UserManager.address,
          MasterManager.address,
          ClubManager.address
        ));
      })
    })
  })
};
