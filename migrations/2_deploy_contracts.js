const Lottery = artifacts.require("Lottery");
const SmallLottery = artifacts.require("SmallLottery");

module.exports = function (deployer) {
  deployer.deploy(Lottery, "0xa44bA3EFB35e04D6120890D7ce6d375031F1Df6D", "0x07688E2E2bC96F83217E5fc05D6730584807c02e"); // TODO: Cambiar owner + token address.
  deployer.deploy(SmallLottery, "0xa44bA3EFB35e04D6120890D7ce6d375031F1Df6D", "0x07688E2E2bC96F83217E5fc05D6730584807c02e"); // TODO: Cambiar owner + token address.
};