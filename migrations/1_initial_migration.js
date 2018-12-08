var Migrations = artifacts.require("./Migrations.sol");
var StandardECMToken = artifacts.require("StandardECMToken");
var AgreementManager = artifacts.require("AgreementManager");
var AgreementFactory = artifacts.require("AgreementFactory");
var EntryState = artifacts.require("EntryState");
var RunningState = artifacts.require("RunningState");
var RemovingState = artifacts.require("RemovingState");

module.exports = function(deployer, network) {
  deployer.deploy(Migrations);

  deployer.deploy(AgreementManager).then(function() {

    return deployer.deploy(StandardECMToken).then(function() {

      return deployer.deploy(RemovingState).then(function() {
        return deployer.deploy(EntryState).then(function() {
          return deployer.deploy(RunningState).then(function() {
            return deployer.deploy(
              AgreementFactory,
              AgreementManager.address,
              StandardECMToken.address,
              [EntryState.address,RunningState.address,RemovingState.address],
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
          })
        })
      })



    });

  });

};
