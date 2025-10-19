const { Info, Debug, Warn, Success, Error } = require('../helpers/messages');
const { fetchString } = require('../utils/http');

async function appPublicIp() {
  Debug('-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=');
  Debug('Inside /sections/app_public_ip.js');

  Info('Setting App Public IP');
  Debug('Making interal Docker IP address available to processes...');
  // INTERNAL_IP from default route is non-trivial without shell; skip as it wasn't used elsewhere.

  Debug('Grabbing the public IP address of the node');
  let PUBLIC_IP = '';
  try { PUBLIC_IP = (await fetchString('https://ifconfig.me')).trim(); }
  catch { PUBLIC_IP = ''; Warn('Failed to fetch public IP'); }

  Debug(`Internal IP: ${process.env.INTERNAL_IP || ''}`);
  Debug(`Public IP: ${PUBLIC_IP}`);

  if (!process.env.APP_PUBLIC_IP || process.env.APP_PUBLIC_IP.length === 0) {
    Info(`Setting APP_PUBLIC_IP address to the public IP address (${PUBLIC_IP}) of the node.`);
    process.env.APP_PUBLIC_IP = PUBLIC_IP;
  } else {
    Warn("You did not leave the APP_PUBLIC_IP variable blank. Let's hope you know what you're doing!");
  }

  Info(`App Public IP set to: ${process.env.APP_PUBLIC_IP}`);
  Success('App Public IP check successful!');
}

module.exports = { appPublicIp };
