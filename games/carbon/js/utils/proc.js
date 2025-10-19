const { spawn } = require('child_process');

function spawnStreaming(cmd, args = [], opts = {}) {
  return new Promise((resolve, reject) => {
    const child = spawn(cmd, args, { stdio: 'inherit', shell: false, ...opts });
    child.on('error', reject);
    child.on('exit', (code, signal) => {
      if (code === 0) resolve({ code });
      else reject(new Error(`${cmd} exited with code ${code}${signal ? ` (signal ${signal})` : ''}`));
    });
  });
}

module.exports = { spawnStreaming };

