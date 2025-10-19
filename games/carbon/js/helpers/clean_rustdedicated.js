const { Info, Debug, Success } = require('./messages');
const path = require('path');
const fs = require('fs');

function fileExists(p) {
  try { fs.accessSync(p, fs.constants.F_OK); return true; } catch { return false; }
}

function Clean_RustDedicated() {
  Debug('Inside function: Clean_RustDedicated()');

  const RUSTEDIT = '/home/container/RustDedicated_Data/Managed/Oxide.Ext.RustEdit.dll';
  const CHAOS = '/home/container/RustDedicated_Data/Managed/Oxide.Ext.Chaos.dll';
  const DISCORD = '/home/container/RustDedicated_Data/Managed/Oxide.Ext.Discord.dll';
  const OXIDEREF = '/home/container/RustDedicated_Data/Managed/Oxide.References.dll.config';
  const DEST_DIR = `/home/container/${process.env.MODDING_ROOT}/extensions/`;

  Debug(`RUSTEDIT: ${RUSTEDIT}`);
  Debug(`CHAOS: ${CHAOS}`);
  Debug(`DISCORD: ${DISCORD}`);
  Debug(`OXIDEREF: ${OXIDEREF}`);
  Debug(`DEST_DIR: ${DEST_DIR}`);

  const fw = process.env.FRAMEWORK || '';
  if (/carbon/.test(fw)) {
    Debug('Carbon Framework Detected!');
    Info('Moving Oxide Extensions to Carbon Directory...');
    if (!fs.existsSync(DEST_DIR)) {
      Info(`Destination directory does not exist. Creating: ${DEST_DIR}`);
      fs.mkdirSync(DEST_DIR, { recursive: true });
    }

    if (fileExists(RUSTEDIT)) { Info('Found Rust Edit Extension! Moving it now...'); fs.renameSync(RUSTEDIT, path.join(DEST_DIR, 'Oxide.Ext.RustEdit.dll')); Success('Rust Edit Extension Moved!'); }
    if (fileExists(CHAOS)) { Info('Found Chaos Code Extension! Moving it now...'); fs.renameSync(CHAOS, path.join(DEST_DIR, 'Oxide.Ext.Chaos.dll')); Success('Chaos Code Extension Moved!'); }
    if (fileExists(DISCORD)) { Info('Found Discord Extension! Moving it now...'); fs.renameSync(DISCORD, path.join(DEST_DIR, 'Oxide.Ext.Discord.dll')); Success('Discord Extension Moved!'); }
  } else if (fw === 'vanilla') {
    Debug('Vanilla framework detected!');
    Info('Checking for Oxide Files in RustDedicated_Data/Managed...');
    // Use shell glob to match; rm will ignore if none
    try {
      const dir = '/home/container/RustDedicated_Data/Managed';
      const files = fs.existsSync(dir) ? fs.readdirSync(dir) : [];
      const oxide = files.filter(n => /^Oxide\..+\.dll$/i.test(n));
      if (oxide.length > 0) {
        Info('Oxide Files Found!');
        Info('Removing Oxide Files...');
        for (const n of oxide) fs.rmSync(`${dir}/${n}`, { force: true });
        Success('Removed all Oxide files from RustDedicated_Data/Managed');
      } else {
        Success('No Oxide Files Found!');
      }
    } catch {
      Success('No Oxide Files Found!');
    }
  }

  if (fileExists(OXIDEREF)) {
    Info('Found Oxide Reference Config! Moving it to the trash now...');
    try { fs.rmSync(OXIDEREF, { force: true }); } catch {}
    Success('Oxide Reference Config Trashed!');
  }
}

module.exports = { Clean_RustDedicated };
