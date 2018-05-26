var Migrations = artifacts.require("./Migrations.sol");
var VirtualWallet = artifacts.require("VirtualWallet");
var AgreementManager = artifacts.require("AgreementManager");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(VirtualWallet).then(function() {
    return deployer.deploy(AgreementManager, VirtualWallet.address);
  });
};
