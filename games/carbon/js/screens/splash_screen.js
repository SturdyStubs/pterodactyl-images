const { Yellow, Info } = require('../helpers/messages');

function splash() {
  // ASCII art from bash was not portable; keep simple banner for clarity.
  Yellow('=== AIO RUST EGG ===');
  Yellow('Created By: SturdyStubs');
  Info('For docs: https://tinyurl.com/aiorustegg');
  Info('Version 4.0.0');
  Info('Starting Egg Now..');
}

module.exports = { splash };

