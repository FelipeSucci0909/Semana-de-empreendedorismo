#!/usr/bin/env python3
"""Gera demo/zelo.html (arquivo único, funciona offline) a partir de demo/src/zelo.html,
embutindo as fontes Lexend e Source Sans 3 (subconjunto latino) em base64.

Uso: python3 demo/build.py
"""
import base64
import pathlib
import re
import urllib.request

ROOT = pathlib.Path(__file__).resolve().parent
SRC = ROOT / "src" / "zelo.html"
OUT = ROOT / "zelo.html"
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
    OUT.write_text(html.replace("/*@FONTS@*/", faces), encoding="utf-8")
    print("Gerado %s (%d KB)" % (OUT.relative_to(ROOT.parent), OUT.stat().st_size // 1024))


if __name__ == "__main__":
    main()
