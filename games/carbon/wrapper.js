#!/usr/bin/env node

var startupCmd = "";
const fs = require("fs");
const seenMessages = new Set(); // Track seen messages to prevent duplicates

// Get the log file from the environment variable, default to 'latest.log' if not set
const logFile = process.env.LOG_FILE || "";

fs.writeFile(logFile, "", (err) => {
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
let rconConnected = false;
let lastSize = 0;
let watcher;

function filterAndOutput(data) {
	const str = data.toString().trim();

	if (seenMessages.has(str)) return; // Prevent duplicate messages
	seenMessages.add(str); // Add message to seen set

	// Filtering logic
	if (str.startsWith("Fallback handler could not load library")) return;
	if (str.includes("Filename:")) return;
	if (str.includes("ERROR: Shader ")) return;
	if (str.includes("WARNING: Shader ")) return;
	if (str.startsWith("Loading Prefab Bundle ")) {
		const percentage = str.substr("Loading Prefab Bundle ".length);
		if (seenPercentage[percentage]) return;

		seenPercentage[percentage] = true;
	}

	console.log(str);
}

var exec = require("child_process").exec;
console.log("Starting Rust...");

var exited = false;
const gameProcess = exec(startupCmd);
gameProcess.stdout.on('data', filterAndOutput);
gameProcess.stderr.on('data', filterAndOutput);
gameProcess.on('exit', function (code, signal) {
	exited = true;

	if (code) {
		console.log("Main game process exited with code " + code);
		// process.exit(code);
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
		rconConnected = true;
		waiting = false;

		// Stop file watching when RCON is connected
		if (watcher) {
			watcher.close();
		}

		// Hack to fix broken console output
		ws.send(createPacket('status'));

		process.stdin.removeListener('data', initialListener);
		gameProcess.stdout.removeListener('data', filterAndOutput);
		gameProcess.stderr.removeListener('data', filterAndOutput);
		process.stdin.on('data', function (text) {
			ws.send(createPacket(text));
		});
	});

	ws.on("message", function (data, flags) {
		try {
			var json = JSON.parse(data);
			if (json !== undefined) {
				if (json.Message !== undefined && json.Message.length > 0) {
					fs.appendFile(logFile, "\n" + json.Message, (err) => {
						if (err) console.log("Callback error in appendFile:" + err);
					});
					filterAndOutput(json.Message); // Apply filtering to WebSocket messages
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

// Function to handle new log data
function handleNewLogData(chunk) {
	if (!rconConnected) {
		filterAndOutput(chunk); // Apply filtering to log data from the file
		lastSize += Buffer.byteLength(chunk, 'utf8'); // Update lastSize to reflect the latest read position
	}
}

// Set up the initial file watcher
if (!rconConnected) {
	// First read any existing data in the file
	fs.stat(logFile, (err, stats) => {
		if (err) return console.error(err);

		if (stats.size > lastSize) {
			logStream = fs.createReadStream(logFile, { encoding: 'utf8', start: lastSize });
			logStream.on('data', handleNewLogData);
			logStream.on('end', () => {
				// Set up file watcher after reading initial data
				watcher = fs.watch(logFile, (event, filename) => {
					if (filename && event === 'change' && !rconConnected) {
						fs.stat(logFile, (err, stats) => {
							if (err) return console.error(err);

							if (stats.size > lastSize) {
								const newLogStream = fs.createReadStream(logFile, { encoding: 'utf8', start: lastSize });
								newLogStream.on('data', handleNewLogData);
							}
						});
					}
				});
			});
		}
	});
}
