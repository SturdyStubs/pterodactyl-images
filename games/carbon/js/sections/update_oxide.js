const { Debug, Info, Error } = require('../helpers/messages');
const { getServerBranch } = require('../helpers/framework');
const { Check_Modding_Root_Folder } = require('../helpers/modding_root_update');
const { fetchToFile } = require('../utils/http');
const { spawnStreaming } = require('../utils/proc');
const fs = require('fs');

async function updateOxide() {
  Debug('-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=');
  Debug('Inside /sections/update_oxide.js');
  Debug('Trying to update Oxide...');

  if (process.env.FRAMEWORK_UPDATE === '1') {
    const fw = (process.env.FRAMEWORK || '').toLowerCase();
    if (fw.startsWith('oxide')) {
      const branch = getServerBranch();
      let url = 'https://github.com/OxideMod/Oxide.Rust/releases/latest/download/Oxide.Rust-linux.zip';
      let label = 'uMod';
      if (branch === 'staging') {
        url = 'https://downloads.oxidemod.com/artifacts/Oxide.Rust/staging/Oxide.Rust-linux.zip';
        label = 'uMod Staging';
      } else if (branch === 'aux01-staging') {
        url = 'https://downloads.oxidemod.com/artifacts/Oxide.Rust/aux01/Oxide.Rust-linux.zip';
        label = 'uMod Aux01';
      }
      Info(`Updating ${label}...`);
      await fetchToFile(url, '/home/container/umod.zip');
      await spawnStreaming('unzip', ['-o', '-q', 'umod.zip'], { cwd: '/home/container' });
      try { fs.unlinkSync('/home/container/umod.zip'); } catch {}
      Check_Modding_Root_Folder();
      Info('Done updating uMod!');
      Info("If you intend to use a different folder name, you'll need to wait until the server boots and the oxide folder is created to rename it.");
    } else {
      Debug(`Framework is set to ${process.env.FRAMEWORK}, skipping Oxide Update!`);
    }
  } else {
    Error('Skipping framework auto update! Did you mean to do this? If not set the Framework Update variable to true!');
  }
}

module.exports = { updateOxide };
