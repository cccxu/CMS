import ManagerCenter from "../build/contracts/ManagerCenter.json";
import ClubManager from "../build/contracts/ClubManager.json";
import UserManager from "../build/contracts/UserManager.json";
import MasterManager from "../build/contracts/MasterManager.json";

const options = {
    web3: {
      block: false,
      fallback: {
        type: 'ws',
        url: 'ws://127.0.0.1:9545'
      }
    },

//       // The contracts to monitor
//   contracts: [SimpleStorage, ComplexStorage, TutorialToken],
//   events: {
//     // monitor SimpleStorage.StorageSet events
//     SimpleStorage: ['StorageSet']
//   },
//   polls: {
//     // check accounts ever 15 seconds
//     accounts: 15000
//   }

    contracts: [ManagerCenter, ClubManager, UserManager, MasterManager],
    // events: {

    // },
    polls: {
        accounts: 15000
    }
}

export default options