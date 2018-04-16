var Migrations = artifacts.require("./Migrations.sol");
var VirtualWallet = artifacts.require("VirtualWallet");
var AgreementManager = artifacts.require("AgreementManager");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(VirtualWallet);
  deployer.deploy(AgreementManager);
};
