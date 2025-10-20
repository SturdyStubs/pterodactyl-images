const { YELLOW } = require('../helpers/colors');
const { Yellow, Info } = require('../helpers/messages');

function endScreen() {
  YELLOW('=== RUST SERVER LAUNCH ===');
  YELLOW('Thats it from us! Enjoy your rust server!');
  Info('For docs: https://tinyurl.com/aiorustegg');
  Info('Starting your Rust server now...');
}

module.exports = { endScreen };