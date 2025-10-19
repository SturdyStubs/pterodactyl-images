const fs = require('fs');
const { Info, Debug, Error, Warn, Success } = require('../helpers/messages');

function moddingRootCheck() {
  Debug('-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=');
  Debug('Inside of /sections/modding_root_check.js');

  Info('Checking Modding Root Folder...');
  const FRAMEWORK = process.env.FRAMEWORK || '';
  const MODDING_ROOT = process.env.MODDING_ROOT || '';

  Debug(`Modding Framework is set to: ${FRAMEWORK}`);

  if (/carbon/.test(FRAMEWORK) || /oxide/.test(FRAMEWORK)) {
    Debug(`MODDING ROOT DIRECTORY set to '${MODDING_ROOT}' for framework '${FRAMEWORK}'.`);

    if (/carbon/.test(FRAMEWORK) && /oxide/.test(MODDING_ROOT)) {
      Error(`ERROR: The modding root '${MODDING_ROOT}' contains the word oxide, but yet you're using the '${FRAMEWORK}'. Please change the name to something that doesn't contain the word oxide.\n`, 1);
    } else if (/oxide/.test(FRAMEWORK) && /carbon/.test(MODDING_ROOT)) {
      Error(`ERROR: The modding root '${MODDING_ROOT}' contains the word carbon, but yet you're using the '${FRAMEWORK}'. Please change the name to something that doesn't contain the word carbon.\n`, 1);
    }

    try {
      if (!fs.existsSync(`/home/container/${MODDING_ROOT}`)) {
        Info(`Creating directory named ${MODDING_ROOT}...`);
        fs.mkdirSync(`/home/container/${MODDING_ROOT}`, { recursive: true });
        Success(`Successfully created directory named ${MODDING_ROOT}.`);
      } else {
        Warn(`${MODDING_ROOT} already exists!`);
      }
    } catch (e) {
      Error(`ERROR: Failed to create the MODDING ROOT DIRECTORY '${MODDING_ROOT}'. Please check your permissions or the directory path.\n`, 1);
    }
  }

  Success('Modding Root Folder Exists Check Complete!');
}

module.exports = { moddingRootCheck };

