#!/usr/bin/env python3
"""Gera o pitch do Zelo a partir de pitch/src/index.html:

- site/pitch/index.html  publicado no Vercel em /pitch (imagens em site/pitch/img/)
- pitch/zelo-pitch.html  arquivo único, com imagens embutidas, que abre offline

Uso: python3 pitch/build.py
"""
import base64
import pathlib
import re
import shutil
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "demo"))
import build as demo_build  # reaproveita fontes e biblioteca de QR da demo

SRC = ROOT / "pitch" / "src" / "index.html"
IMG = ROOT / "pitch" / "img"
SITE = ROOT / "site" / "pitch"
OFFLINE = ROOT / "pitch" / "zelo-pitch.html"


def main():
    html = SRC.read_text(encoding="utf-8")
    html = html.replace("/*@FONTS@*/", demo_build.font_faces())
    html = html.replace("/*@QRLIB@*/", demo_build.QRLIB.read_text(encoding="utf-8"))
    SITE.mkdir(parents=True, exist_ok=True)
    (SITE / "index.html").write_text(html, encoding="utf-8")
    shutil.copytree(IMG, SITE / "img", dirs_exist_ok=True)

    def embutir(m):
        dados = base64.b64encode((IMG / m.group(1)).read_bytes()).decode()
        return f'src="data:image/png;base64,{dados}"'
    OFFLINE.write_text(re.sub(r'src="img/([\w.-]+\.png)"', embutir, html), encoding="utf-8")
    for f in (SITE / "index.html", OFFLINE):
        print("Gerado %s (%d KB)" % (f.relative_to(ROOT), f.stat().st_size // 1024))


if __name__ == "__main__":
    main()
