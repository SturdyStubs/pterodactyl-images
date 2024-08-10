#!/usr/bin/env node

const fs = require("fs");
const path = require("path");
var startupCmd = "";

// Function to find the most recent log file matching the desired format
function findMostRecentLog(directory) {
	const logPattern = /^\d{4}-\d{2}-\d{2}_T\d{4}\.log$/;
	const files = fs.readdirSync(directory);
	let latestFile;
	let latestTime = 0;

	files.forEach(file => {
		if (logPattern.test(file)) {
			const filePath = path.join(directory, file);
			const stat = fs.statSync(filePath);
			if (stat.isFile() && stat.mtimeMs > latestTime) {
				latestTime = stat.mtimeMs;
				latestFile = filePath;
			}
		}
	});

	return latestFile;
}

// Async function to monitor file changes and log the updates
function monitorLogFile(logFilePath) {
	let fileSize = fs.statSync(logFilePath).size;

	fs.watchFile(logFilePath, { interval: 100 }, (curr, prev) => {
		if (curr.mtimeMs > prev.mtimeMs) {
			fs.open(logFilePath, 'r', (err, fd) => {
				if (err) throw err;
				fs.read(fd, Buffer.alloc(curr.size - fileSize), fileSize, curr.size - fileSize, fileSize, (err, bytesRead, buffer) => {
					if (err) throw err;
					console.log(buffer.toString().trim());
					fileSize = curr.size;
				});
			});
		}
	});
}

if (process.env.LOG_FILE === "true") {
	const logDirectory = path.join(__dirname, 'logs'); // Adjusting to use /logs/ directory
	const latestLogFile = findMostRecentLog(logDirectory);
	if (latestLogFile) {
		console.log(`Monitoring log file: ${latestLogFile}`);
		monitorLogFile(latestLogFile);
	} else {
		console.log("No log files found to monitor.");
	}
}

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

var exec = require("child_process").exec;
console.log("Starting Rust...");

var exited = false;
const gameProcess = exec(startupCmd);
gameProcess.stdout.on('data', filter);
gameProcess.stderr.on('data', filter);
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
