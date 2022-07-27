var Horizon = artifacts.require("Horizon");
var HorizonStake = artifacts.require("HorizonStake");

module.exports = function(deployer) {
    deployer.deploy(Horizon);
    deployer.deploy(HorizonStake);
};