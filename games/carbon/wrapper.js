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

var serverStarted = false;  // Flag to indicate if RCON connection is established
const seenPercentage = {};  // Used for filtering out duplicate logs

// Game process startup and log filtering
var exec = require("child_process").exec;
console.log("Starting Rust...");

var exited = false;
const gameProcess = exec(startupCmd);

// Function to filter logs during startup
function filter(data) {
    const str = data.toString();

    // Filters for specific log messages
    if (str.startsWith("Fallback handler could not load library")) return; // Remove fallback handler messages
    if (str.includes("Filename:")) return; // Remove bindings.h errors
    if (str.includes("ERROR: Shader ")) return; // Remove shader errors
    if (str.includes("WARNING: Shader ")) return; // Remove shader warnings
    if (str.includes("The referenced script on this Behaviour")) return; // Remove specific Behaviour script errors
    if (str.includes("RuntimeNavMeshBuilder:")) return; // Remove RuntimeNavMeshBuilder messages
    if (str.startsWith("Loading Prefab Bundle ")) { // Rust spams the same percentage, filter out duplicates
        const percentage = str.substr("Loading Prefab Bundle ".length);
        if (seenPercentage[percentage]) return;
        seenPercentage[percentage] = true;
    }

    // Output the remaining logs
    console.log(str);
}

gameProcess.stdout.on('data', (data) => {
    const str = data.toString();
    filter(str);

    // Detect when the server has fully started by checking logs
    if (str.includes("Game created!") || str.includes("type was")) {
        console.log("Server startup detected. Waiting to connect to RCON...");
    }
});

gameProcess.on('exit', function (code, signal) {
    exited = true;
    if (code) {
        console.log("Main game process exited with code " + code);
    }
});

function poll() {
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
        console.log("Connected to RCON. You can now send commands.");

        // Server is fully ready at this point since RCON is connected
        serverStarted = true;

        // Send a status check to ensure RCON connection works
        ws.send(createPacket('status'));

        // Replace startup command listener with interactive commands
        process.stdin.removeListener('data', initialListener);
        process.stdin.on('data', function (text) {
            ws.send(createPacket(text.trim()));
        });
    });

    ws.on("message", function (data) {
        try {
            var json = JSON.parse(data);
            if (json !== undefined && json.Message !== undefined && json.Message.length > 0) {
                console.log(json.Message);
                // Optionally append the log message to a file
                fs.appendFile("latest.log", "\n" + json.Message, (err) => {
                    if (err) console.log("Callback error in appendFile:" + err);
                });
            }
        } catch (e) {
            console.log(e);
        }
    });

    ws.on("error", function (err) {
        console.log("Waiting for RCON to come up...");
        setTimeout(poll, 5000);  // Retry RCON connection every 5 seconds if not available
    });

    ws.on("close", function () {
        if (!exited) {
            console.log("Connection to server closed.");
            exited = true;
            process.exit();
        }
    });
}

// Initial command listener for stdin
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

// Start the polling (RCON connection attempt)
poll();

process.on('exit', function (code) {
    if (exited) return;
    console.log("Received request to stop the process, stopping the game...");
    gameProcess.kill('SIGTERM');
});