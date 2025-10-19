const { Info, Debug } = require('./messages');
const { spawnStreaming } = require('../utils/proc');
const fs = require('fs');

function deleteSteamApps() {
  Debug('Deleting SteamApps Folder as a precaution...');
  try { fs.rmSync('/home/container/steamapps', { recursive: true, force: true }); } catch {}
}

function frameworkFlag() {
  const fw = process.env.FRAMEWORK || '';
  if (fw.includes('public')) return '-beta public';
  if (fw.includes('aux1')) return '-beta aux01';
  if (fw.includes('aux2')) return '-beta aux02';
  if (fw.includes('staging')) return '-beta staging';
  // Default to public branch if none specified
  return '-beta public';
}

async function SteamCMD_Validate() {
  Debug('Inside Function: SteamCMD_Validate()');
  deleteSteamApps();
  const fw = process.env.FRAMEWORK || '';
  const flag = frameworkFlag();
  const label = flag ? `${flag.replace('-beta ', 'Aux').toUpperCase()} Files` : 'Default Files';
  Info(`Downloading ${label} - Validation On!`);
  await spawnStreaming('./steamcmd/steamcmd.sh', ['+force_install_dir', '/home/container', '+login', 'anonymous', '+app_update', '258550', ...flag.split(' ').filter(Boolean), 'validate', '+quit'], { cwd: '/home/container' });
}

async function SteamCMD_No_Validation() {
  Debug('Inside Function: SteamCMD_No_Validation()');
  const flag = frameworkFlag();
  const label = flag ? `${flag.replace('-beta ', 'Aux').toUpperCase()} Files` : 'Default Files';
  Info(`Downloading ${label} - Validation Off!`);
  await spawnStreaming('./steamcmd/steamcmd.sh', ['+force_install_dir', '/home/container', '+login', 'anonymous', '+app_update', '258550', ...flag.split(' ').filter(Boolean), '+quit'], { cwd: '/home/container' });
}

module.exports = { SteamCMD_Validate, SteamCMD_No_Validation };
