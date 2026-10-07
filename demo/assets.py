#!/usr/bin/env python3
"""Gera os arquivos estáticos do site (site/): ícones do app, manifest (PWA) e
imagem de prévia de link (og.png). Também copia o ícone para o projeto Android.

Uso: python3 demo/assets.py   (precisa de Pillow)
"""
import json
import pathlib
import re
import urllib.request

from PIL import Image, ImageDraw, ImageFont

ROOT = pathlib.Path(__file__).resolve().parent.parent
SITE = ROOT / "site"
TEAL, CLAY, WHITE = (11, 107, 112), (240, 162, 126), (255, 255, 255)


def marca(tamanho, fundo=TEAL, margem=0.0):
    """Ícone do Zelo: arco que 'abraça' um ponto. margem > 0 deixa área segura (ícone adaptável)."""
    S = tamanho * 4
    img = Image.new("RGB", (S, S), fundo)
    d = ImageDraw.Draw(img)
    esc = 1 - 2 * margem
    cx, cy = S // 2, int(S * (0.5 + 0.10 * esc))
    r, w = int(S * 0.29 * esc), int(S * 0.075 * esc)
    d.arc([cx - r, cy - r, cx + r, cy + r], start=180, end=360, fill=WHITE, width=w)
    for x in (cx - r + w // 2, cx + r - w // 2):
        d.ellipse([x - w // 2, cy - w // 2, x + w // 2, cy + w // 2], fill=WHITE)
    pr = int(S * 0.105 * esc)
    d.ellipse([cx - pr, cy - pr, cx + pr, cy + pr], fill=CLAY)
    return img.resize((tamanho, tamanho), Image.LANCZOS)


def fonte_lexend(px):
    cache = ROOT / "demo" / "src" / "fonts" / "Lexend-SemiBold.ttf"
    if not cache.exists():
        # Agente de usuário antigo faz o Google Fonts responder com TTF (o Pillow não lê woff2).
        req = urllib.request.Request("https://fonts.googleapis.com/css2?family=Lexend:wght@600",
                                     headers={"User-Agent": "Mozilla/4.0"})
        css = urllib.request.urlopen(req, timeout=30).read().decode()
        url = re.search(r"url\((https://[^)]+)\)", css).group(1)
        cache.write_bytes(urllib.request.urlopen(url, timeout=30).read())
    return ImageFont.truetype(str(cache), px)


def og():
    W, H = 1200, 630
    img = Image.new("RGB", (W, H), (238, 244, 243))
    d = ImageDraw.Draw(img)
    img.paste(marca(220), (90, 205))
    d.text((360, 190), "zelo", font=fonte_lexend(120), fill=(15, 43, 42))
    d.text((364, 345), "A Zélia marca a consulta e cuida", font=fonte_lexend(40), fill=(74, 98, 97))
    d.text((364, 400), "de todo o caminho até lá.", font=fonte_lexend(40), fill=(74, 98, 97))
    d.text((364, 470), "Toque para testar o app", font=fonte_lexend(34), fill=(180, 83, 42))
    img.save(SITE / "og.png")


def main():
    SITE.mkdir(exist_ok=True)
    for n in (180, 192, 512):
        marca(n).save(SITE / f"icon-{n}.png")
    marca(512, margem=0.12).save(SITE / "icon-maskable-512.png")
    manifest = {
        "name": "Zelo", "short_name": "Zelo", "lang": "pt-BR",
        "description": "A Zélia marca a consulta e cuida de todo o caminho até lá. A família acompanha tudo.",
        "start_url": "./", "scope": "./", "display": "standalone", "orientation": "portrait",
        "background_color": "#EEF4F3", "theme_color": "#EEF4F3",
        "icons": [
            {"src": "icon-192.png", "sizes": "192x192", "type": "image/png"},
            {"src": "icon-512.png", "sizes": "512x512", "type": "image/png"},
            {"src": "icon-maskable-512.png", "sizes": "512x512", "type": "image/png", "purpose": "maskable"},
        ],
    }
    (SITE / "manifest.webmanifest").write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    og()
    # Ícones do app Android (mipmap)
    res = ROOT / "android" / "app" / "src" / "main" / "res"
    for pasta, n in (("mdpi", 48), ("hdpi", 72), ("xhdpi", 96), ("xxhdpi", 144), ("xxxhdpi", 192)):
        destino = res / f"mipmap-{pasta}"
        destino.mkdir(parents=True, exist_ok=True)
        marca(n).save(destino / "ic_launcher.png")
    print("Arquivos do site e ícones do Android gerados.")


if __name__ == "__main__":
    main()
