const { Debug, Info, Warn } = require('./messages');

function lc(val) {
  return (val || '').toString().trim().toLowerCase();
}

function normalizePlatform(input) {
  const v = lc(input);
  if (v.startsWith('carbon')) return 'carbon';
  if (v.startsWith('oxide')) return 'oxide';
  if (v === 'vanilla') return 'vanilla';
  return v || 'vanilla';
}

function parseVersion(input) {
  const v = lc(input);
  const out = { branch: 'public', minimal: false, edge: false, alias: v };
  if (!v) return out;

  // flavor flags
  if (/edge|debug/.test(v)) out.edge = true; // treat Debug as Edge channel for Carbon
  if (/minimal/.test(v)) out.minimal = true;

  // branch aliases
  if (/^public$/.test(v) || /^release$/.test(v)) out.branch = 'public';
  else if (/^staging$/.test(v)) out.branch = 'staging';
  else if (/aux0?1(?:-staging)?/.test(v) || /aux-?1(?:-staging)?/.test(v)) out.branch = 'aux01';
  else if (/aux0?2/.test(v) || /aux-?2/.test(v)) out.branch = 'aux02';
  else if (/aux0?3/.test(v) || /aux-?3/.test(v)) out.branch = 'aux03';
  else if (/last-?month/.test(v)) {
    // No known Steam branch; keep public for safety
    out.branch = 'public';
    out.alias = 'last-month';
  }

  return out;
}

function deriveFromLegacyFramework(framework) {
  const f = lc(framework);
  const result = { platform: normalizePlatform(f), branch: 'public', minimal: false, edge: false };
  if (/staging/.test(f)) result.branch = 'staging';
  else if (/aux0?1/.test(f)) result.branch = 'aux01';
  else if (/aux0?2/.test(f)) result.branch = 'aux02';
  else if (/aux0?3/.test(f)) result.branch = 'aux03';

  if (/minimal/.test(f)) result.minimal = true;
  if (/edge/.test(f)) result.edge = true;
  return result;
}

function getServerBranch() {
  // Prefer VERSION if provided; fall back to legacy FRAMEWORK
  const ver = parseVersion(process.env.VERSION);
  if (process.env.VERSION && process.env.VERSION !== '') return ver.branch;

  const leg = deriveFromLegacyFramework(process.env.FRAMEWORK || '');
  return leg.branch;
}

function getEffectiveFramework() {
  const rawFramework = process.env.FRAMEWORK || '';
  const rawVersion = process.env.VERSION || '';
  const platform = normalizePlatform(rawFramework);
  const ver = parseVersion(rawVersion);

  // If VERSION is not set, respect legacy combined values
  if (!rawVersion) return lc(rawFramework) || 'vanilla';

  if (platform === 'vanilla') return 'vanilla';

  if (platform === 'oxide') {
    return ver.branch === 'staging' ? 'oxide-staging' : 'oxide';
  }

  if (platform === 'carbon') {
    // Edge builds ignore branch and map to edge or edge-minimal
    if (ver.edge) return ver.minimal ? 'carbon-edge-minimal' : 'carbon-edge';

    // Branch-specific builds
    if (ver.branch === 'staging') return ver.minimal ? 'carbon-staging-minimal' : 'carbon-staging';
    if (ver.branch === 'aux01') return ver.minimal ? 'carbon-aux1-minimal' : 'carbon-aux1';
    if (ver.branch === 'aux02') return ver.minimal ? 'carbon-aux2-minimal' : 'carbon-aux2';
    if (ver.branch === 'aux03') return ver.minimal ? 'carbon-aux3-minimal' : 'carbon-aux3';

    // Default public production
    return ver.minimal ? 'carbon-minimal' : 'carbon';
  }

  return platform;
}

function applyFrameworkEnv() {
  const before = process.env.FRAMEWORK || '';
  const effective = getEffectiveFramework();
  const branch = getServerBranch();

  // Only overwrite FRAMEWORK automatically when the admin is using the new split vars
  if ((process.env.VERSION || '') !== '') {
    process.env.FRAMEWORK = effective;
  }
  process.env.RUST_BRANCH = branch; // expose for shell scripts if desired

  Debug(`Framework normalization -> FRAMEWORK: '${before}' => '${process.env.FRAMEWORK}' | VERSION: '${process.env.VERSION || ''}' => branch '${branch}'`);
  if ((process.env.VERSION || '') && !before.includes('-') && before !== effective) {
    Info(`Using combined framework '${effective}' derived from FRAMEWORK='${before}' and VERSION='${process.env.VERSION}'.`);
  }
}

function validateFrameworkVersion() {
  const rawFramework = process.env.FRAMEWORK || '';
  const rawVersion = process.env.VERSION || '';
  // Only enforce when using the new split model
  if (!rawVersion) return { ok: true };

  const platform = normalizePlatform(rawFramework);
  const ver = parseVersion(rawVersion);

  if (platform === 'oxide') {
    const unsupportedBranch = ver.branch !== 'public' && ver.branch !== 'staging';
    const unsupportedFlavor = ver.edge === true; // debug/edge not available for Oxide
    if (unsupportedBranch || unsupportedFlavor) {
      const reason = unsupportedFlavor ? 'debug/edge builds are not available for Oxide.' : `branch '${ver.branch}' is not supported by Oxide.`;
      return {
        ok: false,
        message: `Selected VERSION '${rawVersion}' is not supported for framework 'Oxide' — ${reason} Use 'Public/Release' or 'Staging'.`,
      };
    }
  }

  // Vanilla and Carbon accept listed branches; allow silently
  return { ok: true };
}

module.exports = { getServerBranch, getEffectiveFramework, applyFrameworkEnv, normalizePlatform, parseVersion, validateFrameworkVersion };
