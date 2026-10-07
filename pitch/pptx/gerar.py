"""Gera pitch/zelo-pitch.pptx (editável) a partir de pitch/pptx/build/layout.json.

1. node pitch/pptx/extrair.cjs http://127.0.0.1:8765/pitch/   (com site/ servido)
2. python3 pitch/pptx/gerar.py
Fontes necessárias no computador: pitch/fontes (Lexend Medium/SemiBold, Source Sans 3).
"""
import json
import sys
from pathlib import Path

from lxml import etree
from PIL import Image, ImageFilter
from pptx import Presentation
from pptx.dml.color import RGBColor
from pptx.enum.shapes import MSO_SHAPE
from pptx.enum.text import MSO_ANCHOR, PP_ALIGN
from pptx.oxml.ns import qn
from pptx.util import Emu, Pt

AQUI = Path(__file__).resolve().parent
PITCH = AQUI.parent
BUILD = AQUI / "build"
SAIDA = Path(sys.argv[1]) if len(sys.argv) > 1 else PITCH / "zelo-pitch.pptx"

PX = 9525  # EMU por px (1920 px = 20 in)
MARGEM_SOMBRA = 100  # px em volta das imagens com sombra
# ascendente e descendente (hhea) em frações do tamanho da fonte
METRICAS = {"Lexend": (1.0, 0.25), "Source": (1.024, 0.4)}
# correção medida contra o HTML (o PowerPoint/LibreOffice usa as métricas Win da fonte)
CORRECAO = {"Lexend": 0.046, "Source": 0.17}

FONTES = {
    ("Lexend", 500): ("Lexend Medium", False),
    ("Lexend", 600): ("Lexend SemiBold", False),
    ("Lexend", 700): ("Lexend SemiBold", True),
    ("Source", 400): ("Source Sans 3", False),
    ("Source", 500): ("Source Sans 3", False),
    ("Source", 600): ("Source Sans 3 SemiBold", False),
    ("Source", 700): ("Source Sans 3", True),
}


def emu(v):
    return Emu(int(round(v * PX)))


def preencher(shape, cor):
    if cor:
        shape.fill.solid()
        shape.fill.fore_color.rgb = RGBColor.from_string(cor["hex"])
        if cor["a"] < 1:
            alfa(shape.fill._xPr.find(qn("a:solidFill"))[0], cor["a"])
    else:
        shape.fill.background()


def alfa(el_cor, a):
    sub = etree.SubElement(el_cor, qn("a:alpha"))
    sub.set("val", str(int(a * 100000)))


def sombra(shape, blur, dist, cor, a):
    spPr = shape._element.spPr
    lst = etree.SubElement(spPr, qn("a:effectLst"))
    s = etree.SubElement(lst, qn("a:outerShdw"), blurRad=str(int(blur * PX)), dist=str(int(dist * PX)),
                         dir="5400000", algn="ctr", rotWithShape="0")
    c = etree.SubElement(s, qn("a:srgbClr"), val=cor)
    alfa(c, a)


def sem_borda(shape):
    shape.line.fill.background()


def retangulo(slide, it):
    x, y, w, h, raio = it["x"], it["y"], it["w"], it["h"], it.get("raio") or 0
    borda = it.get("borda")
    canto = it.get("canto")
    rot = 0
    if canto:
        raio = canto["raio"]
        rot = {"tr": 0, "br": 90, "bl": 180, "tl": 270}[canto["canto"]]
        tipo = MSO_SHAPE.ROUND_1_RECTANGLE
        if rot in (90, 270):  # gira em torno do centro: troca largura e altura
            cx, cy = x + w / 2, y + h / 2
            w, h = h, w
            x, y = cx - w / 2, cy - h / 2
    else:
        tipo = MSO_SHAPE.ROUNDED_RECTANGLE if raio > 0.5 else MSO_SHAPE.RECTANGLE
    # borda "fora" (anel de box-shadow) ou borda CSS (dentro da caixa): a linha do
    # PowerPoint fica centrada no contorno, então desloca meia espessura
    if borda:
        d = borda["w"] / 2 if borda.get("fora") else -borda["w"] / 2
        x, y, w, h = x - d, y - d, w + 2 * d, h + 2 * d
        raio = max(raio + d, 0)
    s = slide.shapes.add_shape(tipo, emu(x), emu(y), emu(w), emu(h))
    if rot:
        s.rotation = rot
    if tipo != MSO_SHAPE.RECTANGLE:
        s.adjustments[0] = min(raio / min(w, h), 0.5)
    preencher(s, it.get("fundo"))
    if borda and borda.get("cor"):
        s.line.width = emu(borda["w"])
        s.line.color.rgb = RGBColor.from_string(borda["cor"]["hex"])
    else:
        sem_borda(s)
    if it.get("sombra"):
        sh = it["sombra"]
        sombra(s, sh["blur"], sh["dist"], "0F2B2A", sh["alfa"])
    estilo = s._element.find(qn("p:style"))  # sem o estilo do tema (que traz sombra)
    if estilo is not None:
        s._element.remove(estilo)
    s.text_frame.text = ""
    return s


def com_sombra(src, w_css):
    """drop-shadow(0 26px 40px rgba(8,30,28,.25)) aplicado na própria imagem, para
    seguir o contorno do celular (sombra de imagem no PowerPoint é retangular)."""
    img = Image.open(src).convert("RGBA")
    k = img.width / w_css
    m = int(MARGEM_SOMBRA * k)
    tela = Image.new("RGBA", (img.width + 2 * m, img.height + 2 * m), (8, 30, 28, 0))
    alfa_s = Image.new("L", tela.size, 0)
    alfa_s.paste(img.getchannel("A").point(lambda a: int(a * 0.25)), (m, m + int(26 * k)))
    tela.putalpha(alfa_s.filter(ImageFilter.GaussianBlur(20 * k)))
    tela.alpha_composite(img, (m, m))
    destino = BUILD / "sombra" / Path(src).name
    destino.parent.mkdir(exist_ok=True)
    tela.save(destino)
    return str(destino)


def imagem(slide, it):
    src = str(PITCH.parent / it["arquivo"]) if it.get("arquivo") else str(PITCH / it["src"])
    x, y, w, h = it["x"], it["y"], it["w"], it["h"]
    if it.get("sombra"):
        src = com_sombra(src, w)
        x, y, w, h = x - MARGEM_SOMBRA, y - MARGEM_SOMBRA, w + 2 * MARGEM_SOMBRA, h + 2 * MARGEM_SOMBRA
    return slide.shapes.add_picture(src, emu(x), emu(y), emu(w), emu(h))


def texto(slide, it):
    runs = it["runs"]
    primeira = next(r for r in runs if not r.get("quebra"))
    tam = primeira["tam"]
    # it["y"] é o topo da área do glifo da 1ª linha (ascendente+descendente); no CSS a
    # linha base fica em y + ascendente. Com entrelinha exata o PowerPoint/LibreOffice
    # põe a linha base em topo + entrelinha - descendente, então compensa a diferença.
    asc, desc = METRICAS[primeira["fam"]]
    alt = (asc + desc) * tam
    lh = it["lh"]
    linhas = max(1, round((it["h"] - alt) / lh) + 1)
    if linhas == 1:
        lh = alt
    # uma linha: folga larga para não quebrar; várias: largura exata para quebrar igual
    folga = 20 + it["w"] * 0.1 if linhas == 1 else 1
    x, w = it["x"], it["w"] + folga
    if it["alinh"] == "c":
        x -= folga / 2
    elif it["alinh"] == "r":
        x -= folga
    y = it["y"] + alt - lh - CORRECAO[primeira["fam"]] * tam
    tb = slide.shapes.add_textbox(emu(x), emu(y), emu(w), emu(max(it["h"], lh * linhas)))
    tf = tb.text_frame
    tf.word_wrap = True
    tf.auto_size = None
    tf.margin_left = tf.margin_right = tf.margin_top = tf.margin_bottom = 0
    tf.vertical_anchor = MSO_ANCHOR.TOP
    p = tf.paragraphs[0]
    p.alignment = {"l": PP_ALIGN.LEFT, "c": PP_ALIGN.CENTER, "r": PP_ALIGN.RIGHT}[it["alinh"]]
    p.line_spacing = Pt(lh * 0.75)
    for r in runs:
        if r.get("quebra"):
            p.add_line_break()
            continue
        t = r["t"].upper() if r["caixa"] else r["t"]
        run = p.add_run()
        run.text = t
        nome, negrito = FONTES[(r["fam"], r["peso"])]
        f = run.font
        f.name = nome
        f.bold = negrito
        f.size = Pt(r["tam"] * 0.75)
        f.color.rgb = RGBColor.from_string(r["cor"]["hex"])
        rPr = run._r.get_or_add_rPr()
        rPr.set("kern", "100")  # kerning em todos os tamanhos, como no navegador
        if r["esp"]:
            rPr.set("spc", str(int(round(r["esp"] * 0.75 * 100))))
        for tag in ("a:latin", "a:ea", "a:cs", "a:sym"):
            el = rPr.find(qn(tag))
            if el is None:
                el = etree.SubElement(rPr, qn(tag))
            el.set("typeface", nome)
    return tb


def main():
    slides = json.loads((BUILD / "layout.json").read_text())
    prs = Presentation()
    prs.slide_width, prs.slide_height = emu(1920), emu(1080)
    vazio = prs.slide_layouts[6]
    for n, dados in enumerate(slides, 1):
        s = prs.slides.add_slide(vazio)
        fundo = s.background.fill
        fundo.solid()
        fundo.fore_color.rgb = RGBColor.from_string(dados["fundo"]["hex"])
        for it in dados["itens"]:
            if it["tipo"] == "rect":
                retangulo(s, it)
            elif it["tipo"] in ("img", "raster"):
                imagem(s, it)
            elif it["tipo"] == "texto":
                texto(s, it)
        if dados["notas"]:
            s.notes_slide.notes_text_frame.text = dados["notas"]
    prs.core_properties.title = "Zelo · pitch"
    prs.core_properties.author = "Equipe Zelo"
    prs.save(SAIDA)
    print(f"{SAIDA} · {len(slides)} slides")


if __name__ == "__main__":
    main()
