const https = require('https');
const fs = require('fs');

function fetchStream(url, { maxRedirects = 5, timeoutMs = 300000 } = {}) {
  return new Promise((resolve, reject) => {
    let redirects = 0;
    function requestUrl(currentUrl) {
      const req = https.get(currentUrl, (res) => {
        // Redirects
        if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
          if (redirects++ >= maxRedirects) return reject(new Error('Too many redirects'));
          res.resume();
          return requestUrl(res.headers.location);
        }
        if (res.statusCode !== 200) {
          return reject(new Error(`HTTP ${res.statusCode} for ${currentUrl}`));
        }
        resolve(res);
      });
      req.setTimeout(timeoutMs, () => {
        req.destroy(new Error('HTTP request timeout'));
      });
      req.on('error', reject);
    }
    requestUrl(url);
  });
}

async function fetchToFile(url, filePath, opts) {
  const stream = await fetchStream(url, opts);
  await new Promise((resolve, reject) => {
    const out = fs.createWriteStream(filePath);
    stream.pipe(out);
    out.on('finish', resolve);
    out.on('error', reject);
    stream.on('error', reject);
  });
}

async function fetchString(url, opts) {
  const stream = await fetchStream(url, opts);
  return new Promise((resolve, reject) => {
    let data = '';
    stream.setEncoding('utf8');
    stream.on('data', (chunk) => (data += chunk));
    stream.on('end', () => resolve(data));
    stream.on('error', reject);
  });
}

module.exports = { fetchToFile, fetchString, fetchStream };

