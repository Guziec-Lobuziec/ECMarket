var Migrations = artifacts.require("./Migrations.sol");
var StandardECMToken = artifacts.require("StandardECMToken");
var AgreementManager = artifacts.require("AgreementManager");
var AgreementFactory = artifacts.require("AgreementFactory");

module.exports = function(deployer, network) {
  deployer.deploy(Migrations);

  deployer.deploy(AgreementManager).then(function() {
    return deployer.deploy(StandardECMToken).then(function() {
      return deployer.deploy(
        AgreementFactory,
        AgreementManager.address,
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

      ).then(function() {
        return AgreementManager.deployed();
      }).then(function(manager){
        return manager.setAgreementFactory(AgreementFactory.address);
      });
    });

  });

};
