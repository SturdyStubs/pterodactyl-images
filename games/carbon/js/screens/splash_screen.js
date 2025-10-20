const { YELLOW } = require('../helpers/colors');
const { Red, Info } = require('../helpers/messages');

function splash() {
  // ASCII art from bash was not portable; keep simple banner for clarity.
  YELLOW('=== AIO RUST EGG ===');
  YELLOW('Created By: SturdyStubs');
  Info('For docs: https://tinyurl.com/aiorustegg');
  Info('Version 4.0.0');
  Info('Starting Egg Now..');
}

module.exports = { splash };

