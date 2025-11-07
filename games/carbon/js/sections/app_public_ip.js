const { Info, Debug, Warn, Success } = require('../helpers/messages');
const { fetchString } = require('../utils/http');
const net = require('net');

async function appPublicIp() {
  Debug('-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=');
  Debug('Inside /sections/app_public_ip.js');

  Info('Setting App Public IP');
  Debug('Making interal Docker IP address available to processes...');
  // INTERNAL_IP from default route is non-trivial without shell; skip as it wasn't used elsewhere.

  Debug('Grabbing the public IP address of the node');
  // Try a set of endpoints that return plain text IPs
  const endpoints = [
    'https://ifconfig.me/ip',
    'https://api.ipify.org',
    'https://checkip.amazonaws.com',
  ];

  let PUBLIC_IP = '';
  for (const url of endpoints) {
    try {
      const raw = (await fetchString(url)).trim();
      const ip = raw.split(/\s+/)[0];
      if (net.isIP(ip)) { PUBLIC_IP = ip; break; }
    } catch {
      // try next
    }
  }
  if (!PUBLIC_IP) {
    Warn('Failed to resolve public IP from endpoints; leaving APP_PUBLIC_IP unchanged');
  }

  Debug(`Internal IP: ${process.env.INTERNAL_IP || ''}`);
  Debug(`Public IP: ${PUBLIC_IP}`);

  if (PUBLIC_IP && (!process.env.APP_PUBLIC_IP || process.env.APP_PUBLIC_IP.length === 0)) {
    Info(`Setting APP_PUBLIC_IP to: ${PUBLIC_IP}`);
    process.env.APP_PUBLIC_IP = PUBLIC_IP;
  } else {
    Warn("You did not leave the APP_PUBLIC_IP variable blank. Let's hope you know what you're doing!");
  }

  if (process.env.APP_PUBLIC_IP) Info(`App Public IP set to: ${process.env.APP_PUBLIC_IP}`);
  Success('App Public IP check successful!');
}

module.exports = { appPublicIp };
