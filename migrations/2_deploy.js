const Migrations = artifacts.require("MAP");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
};
