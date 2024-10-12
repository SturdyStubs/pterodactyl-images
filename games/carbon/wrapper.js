#!/usr/bin/env node

var startupCmd = "";
const fs = require("fs");

// Set the LD_LIBRARY_PATH environment variable
process.env.LD_LIBRARY_PATH = `${process.env.LD_LIBRARY_PATH || ""}:${process.cwd()}`;

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
let hostnameDetected = false;  // Flag to detect when hostname has been logged

function filter(data) {
    const str = data.toString();
    
    // Prevent double logging after hostname is detected
    if (hostnameDetected) {
        return;  // Exit if we've already detected the hostname
    }

    // Filters for specific log messages
    if (str.startsWith("Fallback handler could not load library")) return; // Remove fallback handler messages
    if (str.includes("Filename:")) return; // Remove bindings.h errors
    if (str.includes("ERROR: Shader ")) return; // Remove shader errors
    if (str.includes("WARNING: Shader ")) return; // Remove shader warnings
    if (str.includes("The referenced script on this Behaviour")) return; // Remove specific Behaviour script errors
    if (str.startsWith("RuntimeNavMeshBuilder:")) return; // Remove RuntimeNavMeshBuilder messages
    if (str.startsWith("Loading Prefab Bundle ")) { // Rust spams the same percentage, filter out duplicates
        const percentage = str.substr("Loading Prefab Bundle ".length);
        if (seenPercentage[percentage]) return;
        seenPercentage[percentage] = true;
    }

    // Detect when hostname has been logged
    if (str.startsWith("hostname:")) {
        hostnameDetected = true;  // Set the flag to true after first occurrence
    }

    // Output the remaining logs
    console.log(str);
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

        // Send a status check to ensure RCON connection works
        ws.send(createPacket('status'));

        process.stdin.removeListener('data', initialListener);
        process.stdin.on('data', function (text) {
            ws.send(createPacket(text));
        });
    });

    let startupComplete = false;  // Flag to track if the server startup is complete

    ws.on("message", function (data, flags) {
        try {
            var json = JSON.parse(data);
            if (json !== undefined) {
                if (json.Message !== undefined && json.Message.length > 0) {
    
                    // map loading metrics
                    const isMapLoadingLog = json.Message.match(/\[\d+(\.\d+)?s\]/) ||  // timestamps
                                           json.Message.includes("Spawning World") || 
                                           json.Message.includes("Terrain Mesh") ||
                                           json.Message.includes("Rail Meshes") ||
                                           json.Message.includes("Train Track Collation") ||
                                           json.Message.includes("Processing World") ||
                                           json.Message.includes("Finalizing World") ||
                                           json.Message.includes("Cleaning Up") ||
                                           json.Message.includes("Generated ocean patrol path") ||
                                           json.Message.includes("Unloading") ||
                                           json.Message.includes("Asset Warmup") ||
                                           json.Message.includes("Loaded Plugin");
    
                    // send all this too
                    const isImportantLog = json.Message.includes("Asset Warmup") ||
                                           json.Message.includes("Loaded Plugin") ||
                                           json.Message.includes("UpdateNavMesh") ||
                                           json.Message.includes("Starting Navmesh Source Collecting") ||
                                           json.Message.includes("Navmesh Build") ||
                                           json.Message.includes("Monument Navmesh Build") ||
                                           json.Message.includes("Dungeon Navmesh Build") ||
                                           json.Message.includes("entities from map") ||
                                           json.Message.includes("entities from save") ||
                                           json.Message.includes("GlobalNetworkHandler") ||
                                           json.Message.includes("Initializing entity links") ||
                                           json.Message.includes("Stability supports") ||
                                           json.Message.includes("Conditional models") ||
                                           json.Message.includes("Entity save caches") ||
                                           json.Message.includes("Gamemode Convar") ||
                                           json.Message.includes("Server startup complete") ||
                                           json.Message.includes("SteamServer Initialized") ||
                                           json.Message.includes("Spawning") ||
                                           json.Message.includes("Enforcing SpawnPopulation Limits");
    
                    // Regex to capture percentage-based progress messages (e.g., "1%", "99%")
                    const isPercentageLog = json.Message.match(/^\d+%$/);
    
                    // If "Server startup complete" is detected, set the flag to true
                    if (json.Message.includes("Server startup complete")) {
                        startupComplete = true;
                    }
    
                    // After server startup is complete, log all messages to the console
                    if (startupComplete || isMapLoadingLog || isImportantLog || isPercentageLog) {
                        console.log(json.Message);
                    } else {
                        // Only log important messages, map loading info, or percentage logs before startup is complete
                        if (isImportantLog || isMapLoadingLog || isPercentageLog) {
                            console.log(json.Message);
                        }
    
                        // Only log to the console if LOG_FILE is true for non-important messages before startup
                        if (!isImportantLog && !isMapLoadingLog && !isPercentageLog && process.env.LOG_FILE === "true") {
                            console.log(json.Message);
                        }
                    }
    
                    // Always write to the log file
                    fs.appendFile("latest.log", "\n" + json.Message, (err) => {
                        if (err) console.log("Callback error in appendFile:" + err);
                    });
                }
            } else {
                console.log("Error: Invalid JSON received");
            }
        } catch (e) {
            console.log(e);
        }
    });
    
    ws.on("error", function (err) {
        waiting = true;
        console.log("Waiting for RCON to come up...");
        setTimeout(poll, 5000);  // Retry RCON connection every 5 seconds if not available
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
