const Lottery = artifacts.require("Lottery");

module.exports = function (deployer) {
  deployer.deploy(Lottery, "0x1a84F1f9CE6f4bF0FD2b1B4689Db53776e64bF1c", "0x07688E2E2bC96F83217E5fc05D6730584807c02e"); // TODO: Cambiar owner + token address.
};