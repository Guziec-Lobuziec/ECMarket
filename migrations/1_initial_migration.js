var Migrations = artifacts.require("./Migrations.sol");
var StandardECMToken = artifacts.require("StandardECMToken");
var AgreementManager = artifacts.require("AgreementManager");

module.exports = function(deployer, network) {
  deployer.deploy(Migrations);
  deployer.deploy(StandardECMToken).then(function() {
    return deployer.deploy(
      AgreementManager,
      StandardECMToken.address,
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
