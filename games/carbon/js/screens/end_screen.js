const { Yellow, Info } = require('../helpers/messages');

function endScreen() {
  Yellow('=== RUST SERVER LAUNCH ===');
  Yellow('Thats it from us! Enjoy your rust server!');
  Info('For docs: https://tinyurl.com/aiorustegg');
  Info('Starting your Rust server now...');
}

module.exports = { endScreen };
