const { Red, Info } = require('../helpers/messages');

function splash() {
  // ASCII art from bash was not portable; keep simple banner for clarity.
  Red('=== AIO RUST EGG ===');
  Red('Created By: SturdyStubs');
  Info('For docs: https://tinyurl.com/aiorustegg | Support: https://discord.gg/CUH3vADmMp');
  Info('Version 2.0.0');
  Info('Starting Egg Now!');
}

module.exports = { splash };

