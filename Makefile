SHELL := /bin/bash
export DISPLAY ?= :99
PORT ?= 6080

.PHONY: novnc novnc-stop kicad test mcp screenshot

novnc: ## Start Xvfb + fluxbox + VNC + noVNC (set KICAD=1 to also launch kicad)
	@scripts/novnc.sh start
	@if [ "$(KICAD)" = "1" ]; then $(MAKE) --no-print-directory kicad; fi

novnc-stop:
	@scripts/novnc.sh stop

kicad: ## Launch the KiCad project manager on the virtual display
	@scripts/novnc.sh start
	@nohup kicad >/tmp/kicad.log 2>&1 & echo "kicad started (log: /tmp/kicad.log)"

test: ## Smoke test: pcbnew + kipy import, board save, kicad-cli export
	python3 scripts/smoke_test.py

mcp: ## Run the KiCad MCP server over stdio
	@cd /opt/kicad-mcp && node dist/index.js

screenshot: ## Headless KiCad screenshot -> kicad.png
	@scripts/screenshot.sh kicad.png
