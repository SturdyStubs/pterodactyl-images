const { Red, Info } = require('../helpers/messages');

function endScreen() {
  Red('=== RUST SERVER LAUNCH ===');
  Red('Thats it from us! Enjoy your rust server!');
  Info('For docs: https://tinyurl.com/aiorustegg | Support: https://discord.gg/CUH3vADmMp');
  Info('Starting your Rust server now!');
}

module.exports = { endScreen };

