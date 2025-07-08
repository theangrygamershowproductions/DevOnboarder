# Network Troubleshooting

Some development environments restrict outbound network traffic. These tips help you work around common issues.
See [network-exception-list.md](network-exception-list.md) for a list of domains that CI and setup scripts must reach.
Run `scripts/check_network_access.sh` to verify connectivity before continuing.
Run `scripts/show_network_exceptions.sh` to print the domain list if you need to
update your firewall rules.

## Vale download blocked
- Download `vale` from [the releases page](https://github.com/errata-ai/vale/releases) on a machine with internet access.
- Copy the binary to a directory in your `PATH` and make it executable with `chmod +x vale`.
- If you host your own mirror, set the `VALE_BINARY` environment variable to the downloaded path.

## LanguageTool connectivity errors
- Run a local server if `api.languagetool.org` is unreachable:
  ```bash
  docker run -d --name languagetool -p 8010:8010 silviof/docker-languagetool
  ```
- Set `LANGUAGETOOL_URL=http://localhost:8010/v2`.
- Configure `HTTP_PROXY` and `HTTPS_PROXY` if your network requires a proxy.

## npm and pip access
- Set proxy variables before running `npm install` or `pip install`.
- Use an internal registry mirror if available:
  ```bash
  npm config set registry <mirror-url>
  pip config set global.index-url <mirror-url>
  ```

## pre-commit nodeenv SSL errors
- The Prettier hook downloads Node.js using pre-commit's built-in nodeenv. Some
  networks block this download or fail SSL verification.
- Install Node.js 20 manually (see [ubuntu-setup.md](ubuntu-setup.md)) and set
  `PRE_COMMIT_NO_INSTALL=1` so pre-commit uses your system Node instead.
- Re-run `pre-commit install` after exporting the variable.
- If you see an error like `failed to install nodeenv: SSL: CERTIFICATE_VERIFY_FAILED`,
  your network may be blocking the download from `nodejs.org`.
- Run pre-commit on a machine with network access if possible.
- Request CI or firewall exceptions for `nodejs.org` or use a local mirror if available.
- If your organization hosts a Node.js mirror, set the `NODEJS_MIRROR` environment variable before running pre-commit:
  ```bash
  export NODEJS_MIRROR="https://mirror.example.com/nodejs"
  pre-commit run
  ```
