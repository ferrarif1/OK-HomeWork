require("@nomiclabs/hardhat-waffle");
/**
 * @type import('hardhat/config').HardhatUserConfig
 */
const PRIVATE_KEY1 = "e4004b37f5a472c0e10e74d21ec5032795b5fdcfc504ee673e0bafebcc74fea7";
const PRIVATE_KEY2 = "5375e09cf74703ef454ce6f660ee7765ea434c7c775dbdd644c688afc234e434";
const PRIVATE_KEY3 = "ff5297751a835ef0cee39291243020c6c6cd9b45a2387089d17cd790c581bb36";
const PRIVATE_KEY4 = "debe4df7d8dc9fd85c040290959e301c82d9c31c4adc57555b30dd0c4f9f7a2f";

const Goerli_PRIVATE_KEY = "a50419f1862215f5f64168246e978da104b649b7beca8b2bc91227cfc8424853";
module.exports = {
  solidity: "0.7.3",
  networks: {

    ganache: {
      url: `http://127.0.0.1:9545`,
      accounts: [`0x${PRIVATE_KEY1}`,`0x${PRIVATE_KEY2}`,`0x${PRIVATE_KEY3}`,`0x${PRIVATE_KEY4}`]
    },
    goerli: {
      url: `https://goerli.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161`,
      accounts: [`0x${Goerli_PRIVATE_KEY}`]
    }
    // rinkeby: {
    //   url: `https://eth-rinkeby.alchemyapi.io/v2/${ALCHEMY_API_KEY}`,
    //   accounts: [`0x${rinkeby_PRIVATE_KEY}`]
    // },
    
  }

};
