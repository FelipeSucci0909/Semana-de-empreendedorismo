#!/usr/bin/env python3
"""Monta docs/whatsapp/simulacao.html (simulação da conversa com a Zélia no WhatsApp)
com as fontes da demo embutidas. As imagens PNG são geradas a partir dela (ver README)."""
import pathlib, sys
ROOT = pathlib.Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "demo"))
import build  # reaproveita o embutidor de fontes da demo

AQUI = pathlib.Path(__file__).resolve().parent
html = (AQUI / "simulacao.src.html").read_text(encoding="utf-8").replace("/*@FONTS@*/", build.font_faces())
(AQUI / "simulacao.html").write_text(html, encoding="utf-8")
print("ok")
