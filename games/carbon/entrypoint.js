#!/usr/bin/env node
const path = require('path');
const { Debug, Info, Error } = require('./js/helpers/messages');
const { splash } = require('./js/screens/splash_screen');
const { endScreen } = require('./js/screens/end_screen');
const { appPublicIp } = require('./js/sections/app_public_ip');
const { moddingRootCheck } = require('./js/sections/modding_root_check');
const { oxideCarbonSwitch } = require('./js/sections/oxide_carbon_switch');
const { autoUpdateValidate } = require('./js/sections/auto_update_validate');
const { replaceStartupVariables } = require('./js/sections/replace_startup_variables');
const { updateOxide } = require('./js/sections/update_oxide');
const { updateCarbon } = require('./js/sections/update_carbon');
const { extensionDownload } = require('./js/sections/extension_download');
const { spawn } = require('child_process');

(async function main() {
  try {
    // Splash
    console.time('splash');
    splash();
    console.timeEnd('splash');

    // cd /home/container
    process.chdir('/home/container');

    // App public IP fix
    console.time('app_public_ip');
    await appPublicIp();
    console.timeEnd('app_public_ip');

    // Modding root folder exists check
    console.time('modding_root_check');
    moddingRootCheck();
    console.timeEnd('modding_root_check');

    // Oxide -> Carbon switch check
    console.time('oxide_carbon_switch');
    const CARBONSWITCH = oxideCarbonSwitch();
    console.timeEnd('oxide_carbon_switch');

    // Handle auto update / validation
    console.time('auto_update_validate');
    await autoUpdateValidate(CARBONSWITCH);
    console.timeEnd('auto_update_validate');

    // Replace startup variables
    console.time('replace_startup_variables');
    let MODIFIED_STARTUP = replaceStartupVariables();
    console.timeEnd('replace_startup_variables');

    // Update frameworks
    console.time('update_oxide');
    await updateOxide();
    console.timeEnd('update_oxide');
    console.time('update_carbon');
    MODIFIED_STARTUP = await updateCarbon(MODIFIED_STARTUP);
    console.timeEnd('update_carbon');

    // Extension downloader
    if ((process.env.FRAMEWORK || '') !== 'vanilla') {
      console.time('extension_download');
      await extensionDownload();
      console.timeEnd('extension_download');
    } else {
      Info('Skipping Extension Downloads, Vanilla Framework Detected!');
    }

    // Library path fix
    Debug('Defining the Library Path...');
    process.env.LD_LIBRARY_PATH = `${process.cwd()}/RustDedicated_Data/Plugins/x86_64:${process.cwd()}`;

    // End screen
    endScreen();

    // Run the server via wrapper.js
    const args = ['/wrapper.js', MODIFIED_STARTUP];
    const child = spawn('node', args, { stdio: 'inherit', env: process.env });
    child.on('exit', (code, signal) => {
      if (typeof code === 'number') process.exit(code);
      process.exit(0);
    });
  } catch (e) {
    Error(e?.message || String(e), 1);
  }
})();
