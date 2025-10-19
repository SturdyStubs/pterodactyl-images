const { Info, Debug, Success, Error } = require('../helpers/messages');
const { fetchToFile } = require('../utils/http');
const fs = require('fs');

async function extensionDownload() {
  Debug('-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=');
  Debug('Inside of /sections/extension_download.js');

  Info('Checking Extension Downloads...');
  const { RUSTEDIT_EXT, DISCORD_EXT, CHAOS_EXT } = process.env;

  if (RUSTEDIT_EXT === '1' || DISCORD_EXT === '1' || CHAOS_EXT === '1') {
    if ((process.env.FRAMEWORK || '') !== 'vanilla') {
      Debug('Making temp directory...');
      try { fs.mkdirSync('/home/container/temp', { recursive: true }); } catch {}

      const tasks = [];
      if (RUSTEDIT_EXT === '1') {
        Debug('Downloading RustEdit Extension');
        tasks.push(fetchToFile('https://github.com/k1lly0u/Oxide.Ext.RustEdit/raw/master/Oxide.Ext.RustEdit.dll', '/home/container/temp/Oxide.Ext.RustEdit.dll'));
      }
      if (DISCORD_EXT === '1') {
        Debug('Downloading Discord Extension');
        tasks.push(fetchToFile('https://umod.org/extensions/discord/download', '/home/container/temp/Oxide.Ext.Discord.dll'));
      }
      if (CHAOS_EXT === '1') {
        Debug('Downloading Chaos Code Extension');
        tasks.push(fetchToFile('https://chaoscode.io/oxide/Oxide.Ext.Chaos.dll', '/home/container/temp/Oxide.Ext.Chaos.dll'));
      }
      await Promise.all(tasks);
      if (tasks.length > 0) Success('All extension downloads completed!');

      let hasFiles = false;
      try { hasFiles = fs.readdirSync('/home/container/temp').some(n => /^Oxide\.Ext\..+\.dll$/i.test(n)); } catch { hasFiles = false; }
      if (hasFiles) {
        Info('Moving Extensions to appropriate folders...');
        const fw = process.env.FRAMEWORK || '';
        if (/carbon/.test(fw)) {
          Debug('Carbon framework detected!');
          try { fs.mkdirSync(`/home/container/${process.env.MODDING_ROOT}/extensions/`, { recursive: true }); } catch {}
          Info('Moving files...');
          for (const name of fs.readdirSync('/home/container/temp')) {
            if (!/^Oxide\.Ext\..+\.dll$/i.test(name)) continue;
            fs.renameSync(`/home/container/temp/${name}`, `/home/container/${process.env.MODDING_ROOT}/extensions/${name}`);
          }
        }
        if (/oxide/.test(fw)) {
          Debug('Oxide framework detected!');
          for (const name of fs.readdirSync('/home/container/temp')) {
            if (!/^Oxide\.Ext\..+\.dll$/i.test(name)) continue;
            fs.renameSync(`/home/container/temp/${name}`, `/home/container/RustDedicated_Data/Managed/${name}`);
          }
        }
        Success('Move files has completed successfully!');
      } else {
        Success('No Extensions to Move... Skipping the move...');
      }

      Debug('Cleaning up Temp Directory');
      try { fs.rmSync('/home/container/temp', { recursive: true, force: true }); } catch {}
      Debug('Cleanup complete!');
      Success('All downloads complete!');
    } else {
      Error('Framework is vanilla, but you have extension downloads enabled, are you sure that this is what you want?');
    }
  } else {
    Success('No extensions are enabled. Skipping this part...');
  }
}

module.exports = { extensionDownload };
