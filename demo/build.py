#!/usr/bin/env python3
"""Gera a demo do Zelo a partir de demo/src/zelo.html:

- demo/zelo.html  arquivo único que funciona offline (abrir direto no navegador)
- site/index.html a mesma página, publicada no Vercel (site/ tem também ícones,
  manifest e o APK de Android gerado pelo GitHub Actions)

Embute as fontes Lexend e Source Sans 3 (subconjunto latino) e a biblioteca de QR code.

Uso: python3 demo/build.py
"""
import base64
import pathlib
import re
import urllib.request

ROOT = pathlib.Path(__file__).resolve().parent
SRC = ROOT / "src" / "zelo.html"
OUT = ROOT / "zelo.html"
SITE = ROOT.parent / "site" / "index.html"
QRLIB = ROOT / "src" / "vendor" / "qrcode.js"  # qrcode-generator 1.4.4, MIT, Kazuhiko Arase
CACHE = ROOT / "src" / "fonts"
CSS_URL = ("https://fonts.googleapis.com/css2?family=Lexend:wght@500;600"
           "&family=Source+Sans+3:wght@400;600;700&display=swap")
UA = {"User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 14_0) AppleWebKit/605.1.15 "
                    "(KHTML, like Gecko) Version/17.0 Safari/605.1.15"}


def fetch(url):
    with urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=30) as r:
        return r.read()


def font_faces():
    CACHE.mkdir(exist_ok=True)
    css_file = CACHE / "fonts.css"
    if not css_file.exists():
        css_file.write_bytes(fetch(CSS_URL))
    css = css_file.read_text()
    out = []
    # Cada bloco vem precedido de um comentário com o subconjunto (/* latin */ etc.)
    for subset, block in re.findall(r"/\* ([\w-]+) \*/\s*(@font-face \{.*?\})", css, re.S):
        if subset != "latin":
            continue
        url = re.search(r"url\((https://[^)]+)\)", block).group(1)
        name = CACHE / (re.sub(r"\W+", "_", url.split("/s/")[-1]))
        if not name.exists():
            name.write_bytes(fetch(url))
        data = base64.b64encode(name.read_bytes()).decode()
        out.append(block.replace(url, "data:font/woff2;base64," + data))
    return "\n".join(out)


def main():
    html = SRC.read_text(encoding="utf-8")
    try:
        faces = font_faces()
    except Exception as e:  # sem internet: usa fontes do sistema
        print("Aviso: fontes não embutidas (%s); usando fontes do sistema." % e)
        faces = ""
    html = html.replace("/*@FONTS@*/", faces).replace("/*@QRLIB@*/", QRLIB.read_text(encoding="utf-8"))
    for out in (OUT, SITE):
        out.parent.mkdir(exist_ok=True)
        out.write_text(html, encoding="utf-8")
        print("Gerado %s (%d KB)" % (out.relative_to(ROOT.parent), out.stat().st_size // 1024))


if __name__ == "__main__":
    main()
