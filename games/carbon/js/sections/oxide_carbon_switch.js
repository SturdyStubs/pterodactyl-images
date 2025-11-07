const { Info, Debug, Success, Error } = require('../helpers/messages');
const { runQuiet } = require('../utils/shell');

function oxideCarbonSwitch() {
  Debug('-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=');
  Debug('Inside /sections/oxide_carbon_switch.js');

  Info('Detecting if there is a oxide to carbon switch occurring....');
  const FRAMEWORK = process.env.FRAMEWORK || '';

  // If the framework isn't oxide or oxide staging (mimic bash logic)
  if (FRAMEWORK !== 'oxide' || FRAMEWORK !== 'oxide-staging') {
    let CARBONSWITCH = 'FALSE';

    Info('Modding framework is not set to Oxide. Checking if there are left over Oxide files in the server.');
    let hasFiles = false;
    try { runQuiet('ls /home/container/RustDedicated_Data/Managed/Oxide.*.dll'); hasFiles = true; } catch { hasFiles = false; }

    if (hasFiles) {
      Info('Oxide Files Found!');
      Debug(`Framework is: ${FRAMEWORK}`);
      if (/carbon/.test(FRAMEWORK)) {
        Success('Carbon installation detected. Marking Carbon Switch as TRUE!');
        CARBONSWITCH = 'TRUE';
      } else if (/oxide/.test(FRAMEWORK)) {
        Info("Framework is set to a branch of Oxide. This means you're not switching to Carbon!");
      } else {
        Error("If you see this and your framework isn't vanilla, then contact the developers.");
      }
    } else {
      Success('No Oxide files found NOT SWITCHING FROM OXIDE - continuing startup...');
    }

    Debug('==============================');
    Debug(`CARBONSWITCH: ${CARBONSWITCH}`);
    Debug('==============================');
    return CARBONSWITCH;
  }

  return 'FALSE';
}

module.exports = { oxideCarbonSwitch };

