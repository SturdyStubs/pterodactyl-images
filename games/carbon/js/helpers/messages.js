const colors = require('./colors');

function log(color, prefix, msg) {
  const text = prefix ? `${prefix}: ${msg}` : msg;
  process.stdout.write(`${color}${text} ${colors.NC}\n`);
}

function Error(msg, exitCode) {
  log(colors.RED, 'ERROR', msg);
  if (exitCode === 1 || exitCode === '1') process.exit(1);
  if (exitCode === 0 || exitCode === '0') process.exit(0);
}

function Warn(msg) {
  log(colors.YELLOW, 'WARNING', msg);
}

function Info(msg) {
  log(colors.BLUE, '', msg);
}

function Success(msg) {
  log(colors.GREEN, 'SUCCESS', msg);
}

function Debug(msg) {
  if (process.env.EGG_DEBUG === '1') {
    console.log(msg);
  }
}

function Red(msg) { log(colors.RED, '', msg); }
function Yellow(msg) { log(colors.YELLOW, '', msg); }

module.exports = { Error, Warn, Info, Success, Debug, Red, Yellow };
