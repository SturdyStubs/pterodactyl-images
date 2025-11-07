const { Info, Debug, Success } = require('../helpers/messages');
const { spawnSync } = require('child_process');

function replaceStartupVariables() {
  Debug('-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=');
  Debug('Inside /sections/replace_startup_variables.js');

  Info('Replacing Startup Variables...');
  // Preserve exact bash semantics used previously:
  // MODIFIED_STARTUP=$(eval echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')
  const bashCmd = "eval echo \"$STARTUP\" | sed -e 's/{{/${/g' -e 's/}}/}/g'";
  const result = spawnSync('bash', ['-lc', bashCmd], { encoding: 'utf8' });
  if (result.status !== 0) {
    const err = result.stderr || (result.error && result.error.message) || 'Failed to expand STARTUP';
    throw new Error(err);
  }
  const modified = (result.stdout || '').trim();
  Debug(`:/home/container$ ${modified}`);
  Success('Variables replaced!');
  return modified;
}

module.exports = { replaceStartupVariables };

