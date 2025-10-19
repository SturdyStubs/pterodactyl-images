const { Info, Debug, Success } = require('../helpers/messages');
const { runQuiet } = require('../utils/shell');

function replaceStartupVariables() {
  Debug('-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=');
  Debug('Inside /sections/replace_startup_variables.js');

  Info('Replacing Startup Variables...');
  // Preserve exact bash semantics used previously:
  // MODIFIED_STARTUP=$(eval echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')
  const cmd = "bash -lc 'eval echo "$STARTUP" | sed -e '\''s/{{/${/g'\'' -e '\''s/}}/}/g'\'''";
  const out = runQuiet(cmd);
  const modified = (out || '').toString().trim();
  Debug(`:/home/container$ ${modified}`);
  Success('Variables replaced!');
  return modified;
}

module.exports = { replaceStartupVariables };
