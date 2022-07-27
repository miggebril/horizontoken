module.exports = async ({getNamedAccounts,
  deployments,
  getChainId,
  getUnnamedAccounts}) => {
  const {deploy} = deployments;
  const {deployer} = await getUnnamedAccounts();
  await deploy('HorizonToken', {
    from: deployer,
    args: [],
    log: true,
  });
};
module.exports.tags = ['HorizonToken'];
