// const User = artifacts.require("User");
const UserManager = artifacts.require("UserManager");

module.exports = function(deployer) {
//   deployer.deploy(User);
  deployer.deploy(UserManager);
};
