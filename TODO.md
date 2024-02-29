- [X] finish static.yaml solution
- [] finish wireguard config using fastest vpn (probably the chicago one)
- [] check and setup prometheus and node-exporter
- [] setup grafana and extend it to include the new machine 
- [] cron jobs for auto updating every sunday 
  `crontab -e`
  add `0 0 * * 0 sudo apt update && sudo apt upgrade -y` to table
- need to host the text and serve it up over http
- host this stuff on an express server on the cigarbox
- add an endpoint that returns the script text as place text
```js
  const express = require('express');
  const app = express();
  const fs = require('fs');

  app.get('/setup', (req, res) => {
    // Read the bash script file
    fs.readFile('./install.sh', 'utf8', (err, data) => {
      if (err) {
        res.status(500).send('Error reading script file');
      } else {
        res.set('Content-Type', 'text/plain');
        res.send(data);
      }
    });
  });

  const port = 3000; // Specify the port number
  app.listen(port, () => {
    console.log(`Server running on port ${port}`);
  });

```
- another alternative would be to host it on github and hit it like
`https://raw.githubusercontent.com/paperless-ngx/paperless-ngx/main/install-paperless-ngx.sh` but there might be some private stuff that would be an issue here
- checkout paperless-ngx and maybe include it in the install script [https://docs.paperless-ngx.com/setup/]



List of preinstalled linux packages on ubuntu server is at (http://cdimage.ubuntu.com/ubuntu-server/jammy/daily-preinstalled/20240226/jammy-preinstalled-server-arm64+tegra.manifest)

- [] checkout screen multiplexer
  - you can have multiple terminal sessions within a single session
    Ctrl-a c: Create a new window within the screen session.
    Ctrl-a n: Switch to the next window.
    Ctrl-a p: Switch to the previous window.
    Ctrl-a d: Detach the screen session (leaving it running in the background).
    screen -r: Reattach to a detached screen session.
    screen -ls: List all active screen sessions.
-