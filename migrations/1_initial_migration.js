var Migrations = artifacts.require("./Migrations.sol");
var VirtualWallet = artifacts.require("VirtualWallet")

module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(VirtualWallet);
};
