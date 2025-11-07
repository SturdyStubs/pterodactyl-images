const { Info, Warn, Success, Debug } = require('./messages');
const { runQuiet } = require('../utils/shell');

function Check_Modding_Root_Folder() {
  Debug('Inside the function: Check_Modding_Root_Folder()');
  Info('Checking Modding Root Folder to see if moves are required or not...');

  const fw = process.env.FRAMEWORK || '';
  let DEFAULT_ROOT = '';
  if (/carbon/.test(fw)) DEFAULT_ROOT = 'carbon';
  else if (/oxide/.test(fw)) DEFAULT_ROOT = 'oxide';

  Debug(`Default Dir: ${DEFAULT_ROOT}`);
  const MODDING_ROOT = process.env.MODDING_ROOT || DEFAULT_ROOT;

  if (MODDING_ROOT !== DEFAULT_ROOT && /carbon/.test(fw)) {
    Warn('Modding root does not match default root - Carbon');
    Info(`Creating new directories inside ${MODDING_ROOT} - managed, native, tools`);
    runQuiet(`mkdir -p "/home/container/${MODDING_ROOT}/managed/"`);
    runQuiet(`mkdir -p "/home/container/${MODDING_ROOT}/native/"`);
    runQuiet(`mkdir -p "/home/container/${MODDING_ROOT}/tools/"`);
    Info('Moving files...');
    runQuiet(`mv -f "/home/container/carbon/"managed/* "/home/container/${MODDING_ROOT}/managed/" || true`);
    runQuiet(`mv -f "/home/container/carbon/"native/* "/home/container/${MODDING_ROOT}/native/" || true`);
    runQuiet(`mv -f "/home/container/carbon/"tools/* "/home/container/${MODDING_ROOT}/tools/" || true`);
    Success('Moves complete!');
  } else if (MODDING_ROOT !== DEFAULT_ROOT && /oxide/.test(fw)) {
    Warn('Modding root does not match default root - Oxide');
    runQuiet(`mv -f "/home/container/oxide/"* "/home/container/${MODDING_ROOT}/" || true`);
    Success('Moves complete!');
  } else {
    Success('Modding root is the same as default root. Skipping...');
  }
}

module.exports = { Check_Modding_Root_Folder };

