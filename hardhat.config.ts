import "@nomiclabs/hardhat-ethers";
require('hardhat-deploy');
import {HardhatUserConfig} from 'hardhat/types';

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  networks: {
    hardhat: {
    },
    localhost: {
      url: "http://127.0.0.1:7545"
    }
  }
};
export default config;