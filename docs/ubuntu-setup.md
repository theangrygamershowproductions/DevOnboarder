# Ubuntu Setup

These commands install Docker, Docker Compose, Node.js 20, and Python 3.12 on Ubuntu 22.04 or newer.

## Install Docker and Docker Compose
```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## Install Node.js 20
Download the setup script first so it can be reviewed before execution.
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x -o nodesource_setup.sh
# Optional: inspect the script or verify it against the NodeSource repository
sudo bash nodesource_setup.sh
rm nodesource_setup.sh
sudo apt-get install -y nodejs
```

> **Security note:** The repository's policy forbids piping remote scripts
> directly to `bash`. Always download scripts first so you can verify them.

## Install Python 3.12
```bash
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt-get update
sudo apt-get install -y python3.12 python3.12-venv python3.12-dev
```

## Install Project Dependencies

After Python is installed, set up the project in editable mode so tests and
scripts can run:

```bash
pip install -e .  # or `pip install -r requirements.txt` if you created one
pip install -r requirements-dev.txt
```

