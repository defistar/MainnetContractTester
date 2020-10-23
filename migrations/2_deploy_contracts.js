const PerlinRoboAdvisorV1 = artifacts.require('./PerlinRoboAdvisorV1.sol');
const rDai_Kovan = '0x261b45D85cCFeAbb11F022eBa346ee8D1cd488c0';
const dai_Kovan = '0x6B175474E89094C44Da98b954EedeAC495271d0F';
const OWNER = '0x02201cdA77BDaD815984460b38BC4BbDa5ebfA17';

module.exports = function (deployer, network, accounts) {
  // async function getAccountAndKey(accountNdx, mnemonic) {
  //   const MNEMONIC = mnemonic || require('./DEV_MNEMONIC.js').MNEMONIC;
  //   const seed = await bip39.mnemonicToSeed(MNEMONIC);
  //   const hdk = hdkey.fromMasterSeed(seed);
  //   const addr_node = hdk.derivePath(`m/44'/60'/0'/0/${accountNdx}`);
  //   const addr = addr_node.getWallet().getAddressString();
  //   const privKeyBytes = addr_node.getWallet().getPrivateKey();
  //   const privKeyHex = privKeyBytes.toString('hex');
  //   return { addr, privKey: privKeyHex };
  // }

  deployer.then(async () => {
    const MNEMONIC = require('../DEV_MNEMONIC.js').MNEMONIC;

    // const accountAndKey_0 = await getAccountAndKey(0, MNEMONIC);
    // const OWNER = accountAndKey_0.addr;
    // const OWNER_privKey = accountAndKey_0.privKey;
    // console.log(`OWNER : ${OWNER}  - OWNER_privKey : ${OWNER_privKey}`);
    //console.log(`default account: ${accounts[0]}`);

    const perlinRoboAdvisorDeployed = await deployer.deploy(PerlinRoboAdvisorV1, OWNER,  dai_Kovan, rDai_Kovan);
    console.log(`PerlinRoboAdvisor is deployed with Address: ${perlinRoboAdvisorDeployed.address}`);
  });
};
