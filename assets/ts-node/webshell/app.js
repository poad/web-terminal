'use strict';
Object.defineProperty(exports, "__esModule", { value: true });
var express = require("express");
var pty = require("node-pty");
var app = express();
var expressWs = require('express-ws')(app);
// Serve static assets from ./static
app.use(express.static("".concat(__dirname, "/static")));
// Instantiate shell and set up data handlers
expressWs.app.ws('/shell', function (ws, req) {
    // Spawn the shell
    var shell = pty.spawn('ts-node', [], {
        name: 'xterm-color',
        cwd: process.env.PWD,
        env: process.env
    });
    // For all shell data send it to the websocket
    shell.onData(function (data) {
        ws.send(data);
    });
    // For all websocket data send it to the shell
    ws.on('message', function (msg) {
        shell.write(msg);
    });
});
// Start the application
app.listen(3000, '0.0.0.0');
