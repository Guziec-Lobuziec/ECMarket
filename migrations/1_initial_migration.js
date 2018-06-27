var Migrations = artifacts.require("./Migrations.sol");
var VirtualWallet = artifacts.require("VirtualWallet");
var AgreementManager = artifacts.require("AgreementManager");

module.exports = function(deployer, network) {
  deployer.deploy(Migrations);
  deployer.deploy(VirtualWallet).then(function() {
    return deployer.deploy(
      AgreementManager,
      VirtualWallet.address,
      (function(){
        if(network === "development" || network === "coverage"){
          return 10;
        } else {
          return 240; //temporary value
        }
      })(),
      (function(){
        if(network === "development" || network === "coverage"){
          return 10000;
        } else {
          return 161280; //temporary value
        }
      })()
    );
  });
};
