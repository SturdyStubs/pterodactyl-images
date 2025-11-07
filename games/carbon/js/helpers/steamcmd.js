const { Info, Debug } = require('./messages');
const { getServerBranch } = require('./framework');
const { spawnStreaming } = require('../utils/proc');
const fs = require('fs');
const path = require('path');

function deleteSteamApps() {
  Debug('Deleting SteamApps Folder as a precaution...');
  try { fs.rmSync('/home/container/steamapps', { recursive: true, force: true }); } catch {}
}

function frameworkFlag() {
  // Prefer VERSION when provided; fall back to legacy FRAMEWORK detection
  const branch = getServerBranch();
  return `-beta ${branch}`;
}

function frameworkBranch() {
  // Directly return the computed branch (public|staging|aux01|aux02|aux03)
  return getServerBranch();
}

function getDownloadMethod() {
  const raw = (process.env.DOWNLOAD_METHOD || process.env.download_method || 'SteamCMD').toString();
  const method = raw.trim().toLowerCase();
  if (method === 'depotdownloader' || method === 'depot' || method === 'dd') return 'DepotDownloader';
  return 'SteamCMD';
}

async function ensureDepotDownloader() {
  const baseDir = '/home/container';
  const binDir = path.join(baseDir, 'DepotDownloader');
  const binPath = path.join(binDir, 'DepotDownloader');
  try {
    if (fs.existsSync(binPath)) {
      Debug('DepotDownloader already present.');
      return;
    }
  } catch {}

  Info('DepotDownloader not found. Downloading...');
  const url = 'https://github.com/SteamRE/DepotDownloader/releases/download/DepotDownloader_3.4.0/DepotDownloader-linux-x64.zip';
  const zipPath = path.join(baseDir, 'DepotDownloader.zip');

  // Download archive
  await spawnStreaming('curl', ['-L', '-o', zipPath, url], { cwd: baseDir });
  // Prepare directory
  try { fs.rmSync(binDir, { recursive: true, force: true }); } catch {}
  try { fs.mkdirSync(binDir, { recursive: true }); } catch {}
  // Unzip
  await spawnStreaming('unzip', ['-o', zipPath, '-d', binDir], { cwd: baseDir });
  // Ensure executable
  await spawnStreaming('chmod', ['+x', binPath], { cwd: baseDir });
  // Cleanup
  try { fs.rmSync(zipPath, { force: true }); } catch {}
}

async function DepotDownloader_Validate() {
  Debug('Inside Function: DepotDownloader_Validate()');
  await ensureDepotDownloader();
  const branch = frameworkBranch();
  const label = `${branch.toUpperCase()} Files`;
  Info(`Downloading ${label} - Validation On!`);
  const args = ['-app', '258550', '-dir', '/home/container', '-branch', branch, '-validate'];
  await spawnStreaming('/home/container/DepotDownloader/DepotDownloader', args, { cwd: '/home/container' });
}

async function DepotDownloader_No_Validation() {
  Debug('Inside Function: DepotDownloader_No_Validation()');
  await ensureDepotDownloader();
  const branch = frameworkBranch();
  const label = `${branch.toUpperCase()} Files`;
  Info(`Downloading ${label} - Validation Off!`);
  const args = ['-app', '258550', '-dir', '/home/container', '-branch', branch];
  await spawnStreaming('/home/container/DepotDownloader/DepotDownloader', args, { cwd: '/home/container' });
}

async function SteamCMD_Validate() {
  Debug('Inside Function: SteamCMD_Validate()');
  const method = getDownloadMethod();
  if (method === 'DepotDownloader') {
    await DepotDownloader_Validate();
    return;
  }
  // Default: SteamCMD
  deleteSteamApps();
  const flag = frameworkFlag();
  const label = flag ? `${flag.replace('-beta ', 'Aux').toUpperCase()} Files` : 'Default Files';
  Info(`Downloading ${label} - Validation On!`);
  await spawnStreaming('./steamcmd/steamcmd.sh', ['+force_install_dir', '/home/container', '+login', 'anonymous', '+app_update', '258550', ...flag.split(' ').filter(Boolean), 'validate', '+quit'], { cwd: '/home/container' });
}

async function SteamCMD_No_Validation() {
  Debug('Inside Function: SteamCMD_No_Validation()');
  const method = getDownloadMethod();
  if (method === 'DepotDownloader') {
    await DepotDownloader_No_Validation();
    return;
  }
  // Default: SteamCMD
  const flag = frameworkFlag();
  const label = flag ? `${flag.replace('-beta ', 'Aux').toUpperCase()} Files` : 'Default Files';
  Info(`Downloading ${label} - Validation Off!`);
  await spawnStreaming('./steamcmd/steamcmd.sh', ['+force_install_dir', '/home/container', '+login', 'anonymous', '+app_update', '258550', ...flag.split(' ').filter(Boolean), '+quit'], { cwd: '/home/container' });
}

module.exports = { SteamCMD_Validate, SteamCMD_No_Validation };
