const { execSync } = require('child_process');

function run(cmd, options = {}) {
  const defaultOpts = { stdio: ['ignore', 'pipe', 'pipe'], encoding: 'utf8' };
  return execSync(cmd, { ...defaultOpts, ...options });
}

function runQuiet(cmd) {
  try {
    return run(cmd);
  } catch (e) {
    const msg = e?.stdout || e?.stderr || e?.message || '';
    throw new Error(msg.toString());
  }
}

module.exports = { run, runQuiet };

