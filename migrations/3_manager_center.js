const UserManager = artifacts.require("UserManager");
const ClubManager = artifacts.require("ClubManager");
const MasterManager = artifacts.require("MasterManager");
const ManagerCenter = artifacts.require("ManagerCenter");

module.exports = function (deployer) {
    // deployer.deploy(ManagerCenter, UserManager.address, MasterManager.address, ClubManager.address)
    // .then(instance=>{
    //     // UserManager.setManagerCenter(instance.address);
    //     // ClubManager.setManagerCenter(instance.address);
    //     // MasterManager.setManagerCenter(instance.address);
    // })
};