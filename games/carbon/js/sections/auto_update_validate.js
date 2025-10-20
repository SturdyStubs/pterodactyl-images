const { Info, Warn, Debug } = require('../helpers/messages');
const { SteamCMD_Validate, SteamCMD_No_Validation } = require('../helpers/steamcmd');
const { Clean_RustDedicated } = require('../helpers/clean_rustdedicated');

async function autoUpdateValidate(CARBONSWITCH) {
  Debug('-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=');
  Debug('Inside /sections/auto_update_validate.js');

  Info('Handling Auto Update and Validation...');

  if (CARBONSWITCH === 'TRUE') {
    Info('Carbon Switch Detected!');
    Info('Forcing validation of game server...');
    await SteamCMD_Validate();
    Clean_RustDedicated();
  } else if (process.env.AUTO_UPDATE === '1') {
    // Respect VALIDATE setting regardless of framework, unless switching to Carbon
    if (process.env.VALIDATE === '1') {
      await SteamCMD_Validate();
    } else {
      await SteamCMD_No_Validation();
    }
  } else {
    Warn('Not updating server, auto update set to false.');
  }
}

module.exports = { autoUpdateValidate };
