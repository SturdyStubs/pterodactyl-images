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
let rconConnected = false;  // Track RCON connection status

function filter(data) {
    const str = data.toString().trim();  // Trim extra line breaks and spaces

    // Filters for specific log messages
    if (str.startsWith("Fallback handler could not load library")) return; // Remove fallback handler messages
    if (str.includes("Filename:")) return; // Remove bindings.h errors
    if (str.includes("ERROR: Shader ")) return; // Remove shader errors
    if (str.includes("WARNING: Shader ")) return; // Remove shader warnings
    if (str.includes("The referenced script on this Behaviour")) return; // Remove specific Behaviour script errors
    if (str.includes("RuntimeNavMeshBuilder:")) return; // Remove RuntimeNavMeshBuilder messages
    if (str.startsWith("Loading Prefab Bundle ")) { // Filter duplicate percentages
        const percentage = str.substr("Loading Prefab Bundle ".length);
        if (seenPercentage[percentage]) return;
        seenPercentage[percentage] = true;
    }

    // Only output meaningful log lines
    if (str.length > 0) {
        console.log(str);
    }
}

var exec = require("child_process").exec;
console.log("Starting Rust...");

var exited = false;
const gameProcess = exec(startupCmd);

// These will always remain listening for logs from the Rust server
gameProcess.stdout.on('data', filter);
gameProcess.stderr.on('data', filter);

gameProcess.on('exit', function (code, signal) {
    exited = true;
    if (code) {
        console.log("Main game process exited with code " + code);
    }
});

function initialListener(data) {
    const command = data.toString().trim();
    if (command === 'quit') {
        gameProcess.kill('SIGTERM');
    } else if (!rconConnected) {  // Only log if RCON is not connected
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
        console.log("Connected to RCON. You can now send commands.");
        rconConnected = true;

        // Send an initial status check
        ws.send(createPacket('status'));

        // Allow input to be sent via RCON
        process.stdin.removeListener('data', initialListener);
        process.stdin.on('data', function (text) {
            if (rconConnected) {
                ws.send(createPacket(text));
            } else {
                console.log('RCON is not connected.');
            }
        });
    });

    // Handle incoming RCON messages
    ws.on("message", function (data) {
        try {
            var json = JSON.parse(data);
            if (json && json.Message) {
                console.log(json.Message);
                fs.appendFile("latest.log", "\n" + json.Message, (err) => {
                    if (err) console.log("Error writing to log file: " + err);
                });
            }
        } catch (e) {
            console.log("Error parsing RCON message: ", e);
        }
    });

    // Handle WebSocket errors
    ws.on("error", function (err) {
        rconConnected = false;
        console.log("Error connecting to RCON: ", err);
        setTimeout(poll, 10000);  // Retry connecting to RCON in 10 seconds
    });

    // Gracefully handle WebSocket close
    ws.on("close", function () {
        if (rconConnected) {
            console.log("RCON connection closed unexpectedly.");
            rconConnected = false;
            setTimeout(poll, 10000);  // Retry connecting after a delay
        }
    });
};

poll();