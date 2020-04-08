import ClubManager from '../build/contracts/ClubManager.json'
import MasterManager from '../build/contracts/MasterManager.json'
import UserManager from '../build/contracts/UserManager.json'

import ManagerCenter from '../build/contracts/ManagerCenter.json'

const options = {
  web3: {
    block: false,
    fallback: {
      type: 'ws',
      url: 'ws://127.0.0.1:7545'
    }
  },

  contracts: [ClubManager, ManagerCenter, UserManager, ManagerCenter],
  events: {

  },
  polls: {

 accounts: 15000
  }
}

export default options
