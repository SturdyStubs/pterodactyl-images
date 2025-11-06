#!/usr/bin/env node

var startupCmd = "";
const fs = require("fs");
fs.writeFile("latest.log", "", (err) => {
	if (err) console.log("Callback error in appendFile:" + err);
});

var args = process.argv.splice(process.execArgv.length + 2);
for (var i = 0; i < args.length; i++) {
	if (i === args.length - 1) {
		startupCmd += args[i];
	} else {
		startupCmd += args[i] + " ";
	}
}

if (startupCmd.length < 1) {
	console.log("Error: Please specify a startup command.");
	process.exit();
}

const seenPercentage = {};

function filter(data) {
    const str = data.toString();
    if(str.startsWith("Fallback handler could not load library")) return; // Remove fallback
    if(str.includes("Filename:")) return; //Remove bindings.h
	if(str.includes("ERROR: Shader ")) return; //Remove shader errors
	if(str.includes("WARNING: Shader ")) return; //Remove shader errors
    if (str.startsWith("Loading Prefab Bundle ")) { // Rust seems to spam the same percentage, so filter out any duplicates.
        const percentage = str.substr("Loading Prefab Bundle ".length);
        if (seenPercentage[percentage]) return;

        seenPercentage[percentage] = true;
    }

    console.log(str);
}

const { spawn } = require("child_process");
console.log("Starting Rust...");

// Networking/runtime mitigations for Mono/Unity
// - Disable IPv6 in Mono to avoid dual-stack socket issues on some hosts
process.env.MONO_DISABLE_IPV6 = process.env.MONO_DISABLE_IPV6 || '1';
process.env.DOTNET_SYSTEM_NET_DISABLEIPV6 = process.env.DOTNET_SYSTEM_NET_DISABLEIPV6 || '1';
// Optional: enable verbose Mono logging via env toggle MONO_LOGGING
// Accepts: 1/true/yes/on (case-insensitive)
const _monoLoggingRaw = (process.env.MONO_LOGGING || '').toLowerCase();
const _monoLogging = _monoLoggingRaw === '1' || _monoLoggingRaw === 'true' || _monoLoggingRaw === 'yes' || _monoLoggingRaw === 'on';
if (_monoLogging) {
    process.env.MONO_LOG_LEVEL = process.env.MONO_LOG_LEVEL || 'debug';
    process.env.MONO_LOG_MASK = process.env.MONO_LOG_MASK || 'all';
    process.env.MONO_LOG_DEST = process.env.MONO_LOG_DEST || 'file:/home/container/mono-debug.log';
}

// Optional: prevent stdio fds (0/1/2) from being closed via LD_PRELOAD shim
// Controlled by PREVENT_FD toggle: 1/true/yes/on
const _preventFdRaw = (process.env.PREVENT_FD || '').toLowerCase();
const _preventFd = _preventFdRaw === '1' || _preventFdRaw === 'true' || _preventFdRaw === 'yes' || _preventFdRaw === 'on';
if (_preventFd) {
    const preloadPath = '/usr/local/lib/libkeepstdio.so';
    process.env.LD_PRELOAD = process.env.LD_PRELOAD
        ? `${preloadPath}:${process.env.LD_PRELOAD}`
        : preloadPath;
}

// Prefer keeping stdin (fd 0) open to avoid Mono fd reuse
// Spawn via bash -lc to preserve shell expansions present in the startup string
var exited = false;
// Ensure child stdin (fd 0) is a valid file descriptor (map to /dev/null)
// This avoids Mono reusing fd 0 for sockets/files and aborting.
// When MONO_LOGGING is enabled, also run under a PTY via `script` to provide a
// controlling terminal which further reduces the chance of stdio being closed.
let usePty = _monoLogging; // tie PTY usage to MONO_LOGGING as requested
// If PREVENT_FD is enabled, prefer launching directly via bash to avoid any env sanitization by `script`
if (_preventFd) usePty = false;
const spawnCmd = usePty ? 'script' : 'bash';
const spawnArgs = usePty
    ? ['-qfec', startupCmd, '/dev/null']
    : ['-lc', startupCmd];

const gameProcess = spawn(spawnCmd, spawnArgs, {
    stdio: ['ignore', 'pipe', 'pipe'],
    env: process.env
});
// If MONO_LOGGING is enabled, tee raw stdout/stderr to mono-debug.log as a fallback
let monoLogStream = null;
if (_monoLogging) {
    try {
        monoLogStream = fs.createWriteStream('/home/container/mono-debug.log', { flags: 'a' });
    } catch (e) {
        console.log('Failed to open mono-debug.log for writing: ' + (e?.message || e));
    }
}

gameProcess.stdout.on('data', (data) => {
    if (monoLogStream) monoLogStream.write(data);
    filter(data);
});
gameProcess.stderr.on('data', (data) => {
    if (monoLogStream) monoLogStream.write(data);
    filter(data);
});
gameProcess.on('exit', function (code, signal) {
	exited = true;

	if (code) {
		console.log("Main game process exited with code " + code);
		// process.exit(code);
	}
    if (monoLogStream) {
        try { monoLogStream.end(); } catch {}
    }
});

function initialListener(data) {
	const command = data.toString().trim();
	if (command === 'quit') {
		gameProcess.kill('SIGTERM');
	} else {
		console.log('Unable to run "' + command + '" due to RCON not being connected yet.');
	}
}
process.stdin.resume();
process.stdin.setEncoding("utf8");
process.stdin.on('data', initialListener);

process.on('exit', function (code) {
	if (exited) return;

	console.log("Received request to stop the process, stopping the game...");
	gameProcess.kill('SIGTERM');
});

var waiting = true;
var poll = function () {
	function createPacket(command) {
		var packet = {
			Identifier: -1,
			Message: command,
			Name: "WebRcon"
		};
		return JSON.stringify(packet);
	}

	var serverHostname = process.env.RCON_IP ? process.env.RCON_IP : "localhost";
	var serverPort = process.env.RCON_PORT;
	var serverPassword = process.env.RCON_PASS;
	var WebSocket = require("ws");
	var ws = new WebSocket("ws://" + serverHostname + ":" + serverPort + "/" + serverPassword);

	ws.on("open", function open() {
		console.log("Connected to RCON. Generating the map now. Please wait until the server status switches to \"Running\".");
		waiting = false;

		// Hack to fix broken console output
		ws.send(createPacket('status'));

		process.stdin.removeListener('data', initialListener);
		gameProcess.stdout.removeListener('data', filter);
		gameProcess.stderr.removeListener('data', filter);
		process.stdin.on('data', function (text) {
			ws.send(createPacket(text));
		});
	});

	ws.on("message", function (data, flags) {
		try {
			var json = JSON.parse(data);
			if (json !== undefined) {
				if (json.Message !== undefined && json.Message.length > 0) {
					console.log(json.Message);
					const fs = require("fs");
					fs.appendFile("latest.log", "\n" + json.Message, (err) => {
						if (err) console.log("Callback error in appendFile:" + err);
					});
				}
			} else {
				console.log("Error: Invalid JSON received");
			}
		} catch (e) {
			if (e) {
				console.log(e);
			}
		}
	});

	ws.on("error", function (err) {
		waiting = true;
		console.log("Waiting for RCON to come up...");
		setTimeout(poll, 5000);
	});

	ws.on("close", function () {
		if (!waiting) {
			console.log("Connection to server closed.");

			exited = true;
			process.exit();
		}
	});
}
poll();
