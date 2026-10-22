# kicad-pocs

Devcontainer for KiCad proofs of concept: KiCad 9 (PPA), `kicad-cli`, SWIG `pcbnew`,
IPC API client `kipy`, a KiCad MCP server, and a browser desktop via noVNC.

## Use
Open in VS Code / Codespaces ("Reopen in Container"), or `docker build -t kicad-pocs .`.
CI publishes `ghcr.io/thedeepestspace/kicad-pocs-dev:latest` from master.

| Command | What |
|---|---|
| `make test` | smoke test: `import pcbnew`/`kipy`, save a board, `kicad-cli pcb export svg` |
| `make novnc` | start Xvfb + fluxbox + x11vnc + noVNC; open `http://localhost:6080/vnc.html` (port 6080 is forwarded). `KICAD=1 make novnc` also launches KiCad |
| `make kicad` | launch KiCad on the virtual display |
| `make novnc-stop` | stop the display stack |
| `make screenshot` | headless KiCad screenshot to `kicad.png` |
| `make mcp` | run the MCP server on stdio |

## Python
`/opt/venv` is first on `PATH` and uses `--system-site-packages`, so `pcbnew` (SWIG, from the
KiCad package) and `kipy` (`kicad-python`, IPC API) both import. The IPC API needs a running
KiCad with the API enabled (Preferences > Plugins > Enable KiCad API); `kipy` connects via
the socket path in `KICAD_API_SOCKET`.

## MCP
[mixelpixx/KiCAD-MCP-Server](https://github.com/mixelpixx/KiCAD-MCP-Server) (MIT, actively
maintained) is built into `/opt/kicad-mcp` at a pinned commit (`KICAD_MCP_REF` in the
Dockerfile). Client config:

```json
{ "mcpServers": { "kicad": { "command": "node", "args": ["/opt/kicad-mcp/dist/index.js"] } } }
```
Read its README for env vars and tools. Not exercised beyond build and file presence in CI.
