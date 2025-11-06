Purpose
- Provide a ready-to-use Docker daemon config to set default ulimits so Pterodactyl/Wings containers get `nofile=65536:65536` by default.

File
- ops/daemon.json

Option A — Upload file and apply (recommended)
1) Copy the file to your VPS (replace user/host):
   scp ops/daemon.json sturdystubs@vps-cb45d39f:/tmp/daemon.json

2) Install it on the VPS:
   sudo mkdir -p /etc/docker
   sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.bak 2>/dev/null || true
   sudo mv /tmp/daemon.json /etc/docker/daemon.json

3) Restart services:
   sudo systemctl restart docker
   sudo systemctl restart wings

4) Recreate your server container:
   Stop/start the server from the Pterodactyl Panel.

5) Verify:
   sudo cat /etc/docker/daemon.json
   # inside the container shell/console:
   ulimit -n   # should print 65536

Option B — Paste-based install (no file upload)
1) On the VPS, run exactly the following (include the final JSON line on its own):
   sudo mkdir -p /etc/docker
   sudo tee /etc/docker/daemon.json > /dev/null <<'JSON'
   {"default-ulimits":{"nofile":{"Name":"nofile","Soft":65536,"Hard":65536}}}
   JSON

2) Restart services:
   sudo systemctl restart docker
   sudo systemctl restart wings

Notes
- If /etc/docker/daemon.json already has other settings, merge the default-ulimits block instead of overwriting.
- If Docker fails to start, restore the backup and check JSON syntax:
  sudo mv /etc/docker/daemon.json.bak /etc/docker/daemon.json
  sudo systemctl restart docker

