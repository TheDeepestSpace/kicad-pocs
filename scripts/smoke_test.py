#!/usr/bin/env python3
"""Smoke test: pcbnew (SWIG) + kipy import, create/save a board, kicad-cli export."""
import pathlib
import subprocess
import sys
import tempfile

import pcbnew
import kipy  # noqa: F401  (IPC API client; only imported, needs a running KiCad to connect)

with tempfile.TemporaryDirectory() as tmp:
    pcb = pathlib.Path(tmp) / "smoke.kicad_pcb"
    board = pcbnew.BOARD()
    seg = pcbnew.PCB_SHAPE(board)
    seg.SetShape(pcbnew.SHAPE_T_RECT)
    seg.SetStart(pcbnew.VECTOR2I(pcbnew.FromMM(0), pcbnew.FromMM(0)))
    seg.SetEnd(pcbnew.VECTOR2I(pcbnew.FromMM(20), pcbnew.FromMM(10)))
    seg.SetLayer(pcbnew.Edge_Cuts)
    board.Add(seg)
    pcbnew.SaveBoard(str(pcb), board)
    assert pcb.stat().st_size > 0, "board file empty"

    svg = pathlib.Path(tmp) / "out.svg"
    subprocess.run(
        ["kicad-cli", "pcb", "export", "svg", "--layers", "Edge.Cuts",
         "--page-size-mode", "2", "-o", str(svg), str(pcb)],
        check=True,
    )
    assert svg.exists() and svg.stat().st_size > 0, "svg export missing"

print("pcbnew", pcbnew.GetBuildVersion(), "- smoke test OK")
sys.exit(0)
