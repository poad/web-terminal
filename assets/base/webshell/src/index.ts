'use strict';

import * as xterm from 'xterm';
import * as attach from 'xterm-addon-attach';
import * as fit from 'xterm-addon-fit';
import * as links from 'xterm-addon-web-links';

export namespace Index {
  const element = document.getElementById('terminal');
  if (element) {
    const terminal = new xterm.Terminal();
    const fitAddon = new fit.FitAddon();
    terminal.loadAddon(fitAddon);
    terminal.open(element);
    fitAddon.fit();
    terminal.loadAddon(new links.WebLinksAddon());

    // Open the websocket connection to the backend
    const protocol = (location.protocol === 'https:') ? 'wss://' : 'ws://';
    const port = location.port ? `:${location.port}` : '';
    const socketUrl = `${protocol}${location.hostname}${port}/shell`;
    const socket = new WebSocket(socketUrl);
    const attachAddon = new attach.AttachAddon(socket);

    // Attach the socket to the terminal
    socket.onopen = (ev) => { // Attach the socket to term
      terminal.loadAddon(attachAddon);
    };
  }
}
