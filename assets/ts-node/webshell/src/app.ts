'use strict';
import * as express from 'express';
import * as pty from 'node-pty';

const app = express();
const expressWs = require('express-ws')(app);

// Serve static assets from ./static
app.use(express.static(`${__dirname}/static`));

// Instantiate shell and set up data handlers
expressWs.app.ws('/shell', (ws, req) => {
  // Spawn the shell
  const shell = pty.spawn('ts-node', [], {
    name: 'xterm-color',
    cwd: process.env.PWD,
    env: process.env
  });
  // For all shell data send it to the websocket
  shell.onData((data) => {
    ws.send(data);
  });
  // For all websocket data send it to the shell
  ws.on('message', (msg) => {
    shell.write(msg);
  });
});

// Start the application
app.listen(3000, '0.0.0.0');
