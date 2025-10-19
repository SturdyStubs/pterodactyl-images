const { Debug, Info, Error, Success } = require('../helpers/messages');
const { Check_Modding_Root_Folder } = require('../helpers/modding_root_update');
const { fetchStream } = require('../utils/http');
const { spawn } = require('child_process');

function doorstopStartupCarbon(modifiedStartup) {
  process.env.DOORSTOP_ENABLED = '1';
  process.env.DOORSTOP_TARGET_ASSEMBLY = `${process.cwd()}/${process.env.MODDING_ROOT}/managed/Carbon.Preloader.dll`;
  return `LD_PRELOAD=${process.cwd()}/libdoorstop.so ${modifiedStartup}`;
}

async function updateCarbon(modifiedStartup) {
  Debug('-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=');
  Debug('Inside /sections/update_carbon.js');
  Debug('Trying to update Carbon...');

  if (process.env.FRAMEWORK_UPDATE === '1') {
    const fw = process.env.FRAMEWORK || '';
    if (fw === 'carbon') {
      Info('Updating Carbon...');
      await streamTarGz('https://github.com/CarbonCommunity/Carbon.Core/releases/download/production_build/Carbon.Linux.Release.tar.gz');
      Check_Modding_Root_Folder();
      Success('Done updating Carbon!');
      modifiedStartup = doorstopStartupCarbon(modifiedStartup);
    } else if (fw === 'carbon-minimal') {
      Info('Updating Carbon Minimal...');
      await streamTarGz('https://github.com/CarbonCommunity/Carbon/releases/download/production_build/Carbon.Linux.Minimal.tar.gz');
      Check_Modding_Root_Folder();
      Success('Done updating Carbon!');
      modifiedStartup = doorstopStartupCarbon(modifiedStartup);
    } else if (fw === 'carbon-edge') {
      Info('Updating Carbon Edge...');
      await streamTarGz('https://github.com/CarbonCommunity/Carbon/releases/download/edge_build/Carbon.Linux.Debug.tar.gz');
      Check_Modding_Root_Folder();
      Success('Done updating Carbon!');
      modifiedStartup = doorstopStartupCarbon(modifiedStartup);
    } else if (fw === 'carbon-edge-minimal') {
      Info('Updating Carbon Edge Minimal...');
      await streamTarGz('https://github.com/CarbonCommunity/Carbon/releases/download/edge_build/Carbon.Linux.Minimal.tar.gz');
      Check_Modding_Root_Folder();
      Success('Done updating Carbon!');
      modifiedStartup = doorstopStartupCarbon(modifiedStartup);
    } else if (fw === 'carbon-staging') {
      Info('Updating Carbon Staging...');
      await streamTarGz('https://github.com/CarbonCommunity/Carbon/releases/download/rustbeta_staging_build/Carbon.Linux.Debug.tar.gz');
      Check_Modding_Root_Folder();
      Success('Done updating Carbon!');
      modifiedStartup = doorstopStartupCarbon(modifiedStartup);
    } else if (fw === 'carbon-staging-minimal') {
      Info('Updating Carbon Staging Minimal...');
      await streamTarGz('https://github.com/CarbonCommunity/Carbon/releases/download/rustbeta_staging_build/Carbon.Linux.Minimal.tar.gz');
      Check_Modding_Root_Folder();
      Success('Done updating Carbon!');
      modifiedStartup = doorstopStartupCarbon(modifiedStartup);
    } else if (fw === 'carbon-aux1') {
      Info('Updating Carbon Aux1...');
      await streamTarGz('https://github.com/CarbonCommunity/Carbon/releases/download/rustbeta_aux01_build/Carbon.Linux.Debug.tar.gz');
      Check_Modding_Root_Folder();
      Success('Done updating Carbon!');
      modifiedStartup = doorstopStartupCarbon(modifiedStartup);
    } else if (fw === 'carbon-aux1-minimal') {
      Info('Updating Carbon Aux1 Minimal...');
      await streamTarGz('https://github.com/CarbonCommunity/Carbon/releases/download/rustbeta_aux01_build/Carbon.Linux.Minimal.tar.gz');
      Check_Modding_Root_Folder();
      Success('Done updating Carbon!');
      modifiedStartup = doorstopStartupCarbon(modifiedStartup);
    } else if (fw === 'carbon-aux2') {
      Info('Updating Carbon Aux2...');
      await streamTarGz('https://github.com/CarbonCommunity/Carbon/releases/download/rustbeta_aux02_build/Carbon.Linux.Debug.tar.gz');
      Check_Modding_Root_Folder();
      Success('Done updating Carbon!');
      modifiedStartup = doorstopStartupCarbon(modifiedStartup);
    } else if (fw === 'carbon-aux2-minimal') {
      Info('Updating Carbon Aux2 Minimal...');
      await streamTarGz('https://github.com/CarbonCommunity/Carbon/releases/download/rustbeta_aux02_build/Carbon.Linux.Minimal.tar.gz');
      Check_Modding_Root_Folder();
      Success('Done updating Carbon!');
      modifiedStartup = doorstopStartupCarbon(modifiedStartup);
    } else if (fw === 'carbon-aux3-minimal') {
      Info('Updating Carbon Aux3 Minimal...');
      await streamTarGz('https://github.com/CarbonCommunity/Carbon/releases/download/rustbeta_aux03_build/Carbon.Linux.Debug.tar.gz');
      Check_Modding_Root_Folder();
      Success('Done updating Carbon!');
      modifiedStartup = doorstopStartupCarbon(modifiedStartup);
    } else if (fw === 'carbon-aux3') {
      Info('Updating Carbon Aux3 Minimal...');
      await streamTarGz('https://github.com/CarbonCommunity/Carbon/releases/download/rustbeta_aux03_build/Carbon.Linux.Minimal.tar.gz');
      Check_Modding_Root_Folder();
      Success('Done updating Carbon!');
      modifiedStartup = doorstopStartupCarbon(modifiedStartup);
    }
  } else {
    Error('Skipping framework auto update! Did you mean to do this? If not set the Framework Update variable to true!');
  }

  return modifiedStartup;
}

async function streamTarGz(url) {
  const res = await fetchStream(url);
  await new Promise((resolve, reject) => {
    const tar = spawn('tar', ['-xz', '-f', '-'], { cwd: '/home/container' });
    res.pipe(tar.stdin);
    tar.on('exit', (code) => (code === 0 ? resolve() : reject(new Error(`tar exited with ${code}`))));
    tar.on('error', reject);
    res.on('error', reject);
  });
}

module.exports = { updateCarbon };
