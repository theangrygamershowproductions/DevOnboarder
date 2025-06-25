# Network Troubleshooting

Some development environments restrict outbound network traffic. These tips help you work around common issues.

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
