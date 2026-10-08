"""Gera docs/zelo-ebit-preliminar.xlsx: DRE de 3 anos do Zelo, com premissas editáveis.

python3 docs/gerar_ebit.py  (depois, recalcular no Excel/LibreOffice ao abrir)
Todas as premissas são hipóteses a validar.
"""
from pathlib import Path

from openpyxl import Workbook
from openpyxl.styles import Alignment, Font, PatternFill
from openpyxl.utils import get_column_letter

SAIDA = Path(__file__).resolve().parent / "zelo-ebit-preliminar.xlsx"

AZUL = Font(name="Arial", size=11, color="FF0000FF")
NORMAL = Font(name="Arial", size=11)
NEGRITO = Font(name="Arial", size=11, bold=True)
TITULO = Font(name="Arial", size=14, bold=True)
NOTA = Font(name="Arial", size=11, color="FF555555")
CAB = Font(name="Arial", size=11, bold=True, color="FFFFFFFF")
FUNDO_CAB = PatternFill("solid", fgColor="FF0B6B70")
AMARELO = PatternFill("solid", fgColor="FFFFFF00")

RS = '"R$ "#,##0;"(R$ "#,##0\\);\\-'
RS2 = '"R$ "#,##0.00;"(R$ "#,##0.00\\);\\-'
PCT = '0.0%;\\(0.0%\\);\\-'
NUM = '#,##0;\\(#,##0\\);\\-'
NUM1 = '#,##0.0;\\(#,##0.0\\);\\-'

wb = Workbook()

# ---------------------------------------------------------------- Premissas
pr = wb.active
pr.title = "Premissas"
pr["A1"] = "Zelo — Premissas (todas são hipóteses a validar)"
pr["A1"].font = TITULO
pr["A2"] = "Edite as células em azul. Amarelo = premissas que mais mexem no resultado."
pr["A2"].font = NOTA

P = {}  # nome -> referência absoluta "Premissas!$B$n"
linha = 4


def secao(titulo):
    global linha
    pr.cell(linha, 1, titulo).font = CAB
    for c in range(1, 4):
        pr.cell(linha, c).fill = FUNDO_CAB
    linha += 1


def premissa(nome, rotulo, valor, fmt, nota="", chave=False):
    global linha
    pr.cell(linha, 1, rotulo).font = NORMAL
    c = pr.cell(linha, 2, valor)
    c.font, c.number_format = AZUL, fmt
    if chave:
        c.fill = AMARELO
    pr.cell(linha, 3, nota).font = NOTA
    P[nome] = f"Premissas!$B${linha}"
    linha += 1


secao("PREÇOS (o que a família paga)")
premissa("acomp", "Acompanhante (bloco de até 4h)", 180, RS, "Sugestão do grupo; entrevista: ~R$ 300 pelo DIA inteiro", True)
premissa("transp", "Transporte ida e volta (até 15 km)", 80, RS, "Definido pelo grupo")
premissa("adapt", "Adicional veículo adaptado (rampa)", 60, RS, "Estimativa")
premissa("taxa", "Taxa de serviço por atendimento (plano Grátis)", 15, RS, "Isenta no Zelo+ e no Zelo Empresas")
premissa("zplus", "Zelo+ (mensal por família)", 29.9, RS2, "Definido pelo grupo")
secao("ZELO EMPRESAS (o que a empresa paga)")
premissa("pepm", "Mensalidade por funcionário (todos os funcionários)", 5, RS2,
         "Modelo de benefício: a empresa paga por funcionário, use ou não. Inclui Zelo+ para quem tem pais idosos", True)
premissa("func", "Funcionários por empresa cliente (média)", 500, NUM, "Empresas médias e grandes de SP")
secao("MIX DOS ATENDIMENTOS")
premissa("p_acomp", "% dos atendimentos com acompanhante", 0.8, PCT, "Estimativa")
premissa("p_transp", "% dos atendimentos com transporte", 0.95, PCT, "Estimativa")
premissa("p_adapt", "% dos atendimentos com veículo adaptado", 0.1, PCT, "Estimativa")
secao("CUSTOS VARIÁVEIS")
premissa("repasse", "Repasse ao acompanhante (% do preço)", 0.75, PCT, "Zelo fica com 25%", True)
premissa("carro", "Custo do carro ida e volta (99/Uber/táxi)", 60, RS, "Estimativa: 2 corridas de ~6 km em SP")
premissa("frota", "Custo adicional da frota adaptada", 45, RS, "Estimativa")
premissa("pgto", "Taxa de pagamento (% do valor cobrado)", 0.03, PCT, "Cartão/Pix intermediado; não incide no boleto B2B")
premissa("seguro", "Seguro de acidentes pessoais por atendimento", 4, RS, "Estimativa")
premissa("ia_at", "IA + WhatsApp por atendimento", 3, RS, "Conversa de agendamento + avisos do dia")
premissa("ia_fam", "IA + WhatsApp por família ativa no mês", 1.5, RS2, "Lembretes, perguntas")
premissa("imposto", "Impostos sobre a receita própria do Zelo", 0.08, PCT,
         "Simples Nacional, estimativa. Base = entradas − repasses − carros")
for col, w in (("A", 52), ("B", 14), ("C", 84)):
    pr.column_dimensions[col].width = w

# ---------------------------------------------------------------- DRE
d = wb.create_sheet("DRE 3 anos")
d["A1"] = "Zelo — DRE preliminar de 3 anos (R$ por ano)"
d["A1"].font = TITULO
d["A2"] = "Cenário-base · modelo: acompanhante Zelo + carro sob demanda · B2B cobrado por funcionário"
d["A2"].font = NOTA
ANOS = ["Ano 1", "Ano 2", "Ano 3"]
COLS = ["B", "C", "D"]
for j, t in enumerate(["Linha"] + ANOS + ["Como é calculado"]):
    c = d.cell(4, j + 1, t)
    c.font, c.fill = CAB, FUNDO_CAB
d.freeze_panes = "B5"

R = {}  # nome -> número da linha
linha = 5


def cab(titulo):
    global linha
    d.cell(linha, 1, titulo).font = NEGRITO
    linha += 1


def entrada(nome, rotulo, valores, fmt, nota=""):
    global linha
    d.cell(linha, 1, rotulo).font = NORMAL
    for col, v in zip(COLS, valores):
        c = d[f"{col}{linha}"]
        c.value, c.font, c.number_format = v, AZUL, fmt
    d.cell(linha, 5, nota).font = NOTA
    R[nome] = linha
    linha += 1


def formula(nome, rotulo, f, fmt=RS, nota="", negrito=False, destaque=False):
    """f(col) devolve a fórmula da coluna; use {x} para linhas: f'={col}{R["a"]}'"""
    global linha
    d.cell(linha, 1, rotulo).font = NEGRITO if negrito else NORMAL
    for col in COLS:
        c = d[f"{col}{linha}"]
        c.value, c.number_format = f(col), fmt
        c.font = NEGRITO if negrito else NORMAL
        if destaque:
            c.fill = AMARELO
    d.cell(linha, 5, nota).font = NOTA
    R[nome] = linha
    linha += 1


def r(nome, col):
    return f"{col}{R[nome]}"


cab("VOLUME (premissas de cada ano, média mensal)")
entrada("fam_b2c", "Famílias B2C ativas", [250, 1000, 2500], NUM, "famílias que contratam por conta própria")
entrada("pct_plus", "% das famílias B2C no Zelo+", [0.15, 0.2, 0.25], PCT)
entrada("freq_b2c", "Atendimentos por família B2C por mês", [0.8, 0.8, 0.8], NUM1)
entrada("empresas", "Empresas clientes (média no ano)", [5, 30, 90], NUM, "ex.: piloto com 3 empresas, 5 no fim do ano 1")
entrada("ativ", "% dos funcionários com família ativa no mês", [0.03, 0.04, 0.05], PCT,
        "funcionários de 35 a 60 anos que levam os pais ao médico")
entrada("freq_b2b", "Atendimentos por família B2B por mês", [1.0, 1.0, 1.0], NUM1, "o benefício estimula o uso")
formula("funcs", "Funcionários cobertos", lambda c: f"={r('empresas', c)}*{P['func']}", NUM)
formula("fam_b2b", "Famílias B2B ativas", lambda c: f"={r('funcs', c)}*{r('ativ', c)}", NUM)
formula("at_mes", "Atendimentos por mês", lambda c: f"={r('fam_b2c', c)}*{r('freq_b2c', c)}+{r('fam_b2b', c)}*{r('freq_b2b', c)}", NUM)
formula("at", "Atendimentos no ano", lambda c: f"={r('at_mes', c)}*12", NUM)
formula("pct_b2b", "% dos atendimentos vindos do B2B",
        lambda c: f"=IF({r('at_mes', c)}=0,0,{r('fam_b2b', c)}*{r('freq_b2b', c)}/{r('at_mes', c)})", PCT)
formula("isentos", "% dos atendimentos isentos da taxa",
        lambda c: f"=IF({r('at_mes', c)}=0,0,({r('fam_b2c', c)}*{r('pct_plus', c)}*{r('freq_b2c', c)}+{r('fam_b2b', c)}*{r('freq_b2b', c)})/{r('at_mes', c)})",
        PCT, "famílias Zelo+ e Zelo Empresas não pagam taxa")
linha += 1

cab("ENTRADAS (dinheiro que entra)")
formula("r_acomp", "Acompanhantes", lambda c: f"={r('at', c)}*{P['p_acomp']}*{P['acomp']}", nota="atendimentos × % com acompanhante × preço")
formula("r_transp", "Transporte", lambda c: f"={r('at', c)}*{P['p_transp']}*{P['transp']}")
formula("r_adapt", "Adicional veículo adaptado", lambda c: f"={r('at', c)}*{P['p_adapt']}*{P['adapt']}")
formula("r_taxa", "Taxa de serviço (plano Grátis)", lambda c: f"={r('at', c)}*(1-{r('isentos', c)})*{P['taxa']}")
formula("r_plus", "Assinaturas Zelo+", lambda c: f"={r('fam_b2c', c)}*{r('pct_plus', c)}*{P['zplus']}*12")
formula("r_b2b", "Zelo Empresas (mensalidade por funcionário)", lambda c: f"={r('funcs', c)}*{P['pepm']}*12",
        nota="receita recorrente, faturada por boleto à empresa", destaque=True)
formula("rec", "Total de entradas", lambda c: f"=SUM({c}{R['r_acomp']}:{c}{R['r_b2b']})", negrito=True)
formula("rec_propria", "Receita própria do Zelo (entradas − repasses − carros)",
        lambda c: f"={r('rec', c)}+{c}{R['r_b2b'] + 3}+{c}{R['r_b2b'] + 4}+{c}{R['r_b2b'] + 5}", nota="o que é de fato do Zelo")
linha += 1

cab("SAÍDAS VARIÁVEIS")
formula("c_rep", "Repasse aos acompanhantes", lambda c: f"=-{r('r_acomp', c)}*{P['repasse']}")
formula("c_carro", "Carros sob demanda (99/Uber/táxi)", lambda c: f"=-{r('at', c)}*{P['p_transp']}*{P['carro']}")
formula("c_frota", "Frota adaptada parceira", lambda c: f"=-{r('at', c)}*{P['p_adapt']}*{P['frota']}")
# corrige a receita própria para apontar para as linhas certas
for col in COLS:
    d[f"{col}{R['rec_propria']}"] = f"={r('rec', col)}+{r('c_rep', col)}+{r('c_carro', col)}+{r('c_frota', col)}"
formula("c_pgto", "Taxa de pagamento", lambda c: f"=-({r('rec', c)}-{r('r_b2b', c)})*{P['pgto']}", nota="sobre tudo, menos o boleto B2B")
formula("c_seg", "Seguro por atendimento", lambda c: f"=-{r('at', c)}*{P['seguro']}")
formula("c_ia", "IA + WhatsApp",
        lambda c: f"=-({r('at', c)}*{P['ia_at']}+({r('fam_b2c', c)}+{r('fam_b2b', c)})*12*{P['ia_fam']})")
formula("c_imp", "Impostos sobre a receita própria", lambda c: f"=-{r('rec_propria', c)}*{P['imposto']}")
formula("mc", "Margem de contribuição", lambda c: f"={r('rec', c)}+SUM({c}{R['c_rep']}:{c}{R['c_imp']})", negrito=True)
formula("mc_pct", "Margem de contribuição (% das entradas)", lambda c: f"=IF({r('rec', c)}=0,0,{r('mc', c)}/{r('rec', c)})", PCT)
linha += 1

cab("CUSTOS FIXOS (média mensal no ano; azul = editável)")
FIXOS = [
    ("f_ops", "Equipe de operação e atendimento (com encargos)", [12000, 32000, 60000], "2 / 5 / 9 pessoas; a Zélia faz o agendamento"),
    ("f_pro", "Pró-labore dos fundadores", [9000, 18000, 30000], "3 fundadores"),
    ("f_tec", "Tecnologia (desenvolvimento e nuvem)", [10000, 25000, 40000], ""),
    ("f_mkt", "Marketing e aquisição de famílias B2C", [8000, 15000, 25000], "menor porque o B2B traz famílias sem custo de aquisição"),
    ("f_rec", "Recrutamento e treinamento de parceiros", [4000, 8000, 15000], ""),
    ("f_ven", "Vendas B2B (RH)", [8000, 15000, 28000], "1 / 2 / 3 vendedores"),
    ("f_adm", "Jurídico, contábil e administrativo", [4000, 7000, 12000], ""),
]
for nome, rot, vals, nota in FIXOS:
    entrada(nome, rot, vals, RS, nota)
formula("fixo_mes", "Total de custos fixos por mês", lambda c: f"=SUM({c}{R['f_ops']}:{c}{R['f_adm']})")
formula("fixo", "Total de custos fixos no ano", lambda c: f"=-{r('fixo_mes', c)}*12", negrito=True)
linha += 1

cab("RESULTADO")
formula("ebitda", "EBITDA", lambda c: f"={r('mc', c)}+{r('fixo', c)}")
entrada("da", "Depreciação e amortização", [6000, 20000, 40000], RS, "notebooks, desenvolvimento do app")
formula("ebit", "EBIT", lambda c: f"={r('ebitda', c)}-{r('da', c)}", negrito=True, destaque=True)
formula("ebit_pct", "Margem EBIT (% das entradas)", lambda c: f"=IF({r('rec', c)}=0,0,{r('ebit', c)}/{r('rec', c)})", PCT)
formula("acum", "EBIT acumulado",
        lambda c: f"={r('ebit', c)}" if c == "B" else f"={COLS[COLS.index(c) - 1]}{linha}+{r('ebit', c)}",
        negrito=True, nota="vira positivo = o investimento do ano 1 se pagou")
linha += 1

cab("PONTO DE EQUILÍBRIO")
formula("m_b2b", "Margem da mensalidade B2B no ano", lambda c: f"={r('r_b2b', c)}*(1-{P['imposto']})",
        nota="quase toda a mensalidade vira margem")
formula("m_at", "Margem por atendimento (sem B2B)",
        lambda c: f"=IF({r('at', c)}=0,0,({r('mc', c)}-{r('m_b2b', c)})/{r('at', c)})", RS2)
formula("pe", "Atendimentos/mês para EBIT = 0",
        lambda c: f"=IF({r('m_at', c)}<=0,0,(-{r('fixo', c)}+{r('da', c)}-{r('m_b2b', c)})/{r('m_at', c)}/12)", NUM,
        nota="mantendo os custos fixos e o B2B do ano")
formula("pe_sem", "Atendimentos/mês para EBIT = 0 sem o B2B",
        lambda c: f"=IF({r('m_at', c)}<=0,0,(-{r('fixo', c)}+{r('da', c)})/{r('m_at', c)}/12)", NUM)
formula("ebit_sem", "EBIT se a mensalidade B2B fosse zero", lambda c: f"={r('ebit', c)}-{r('m_b2b', c)}",
        nota="por que o Zelo Empresas é prioridade")
d.column_dimensions["A"].width = 52
for col in COLS:
    d.column_dimensions[col].width = 17
d.column_dimensions["E"].width = 60

# ---------------------------------------------------------------- Sensibilidade
s = wb.create_sheet("Sensibilidade")
s["A1"] = "EBIT por ano conforme a mensalidade por funcionário do Zelo Empresas"
s["A1"].font = TITULO
s["A2"] = "Cada R$ 1 a mais por funcionário vira receita quase sem custo (só imposto). Demais premissas como na DRE."
s["A2"].font = NOTA
for j, t in enumerate(["R$ por funcionário/mês"] + ANOS):
    c = s.cell(4, j + 1, t)
    c.font, c.fill = CAB, FUNDO_CAB
for i, v in enumerate([0, 2, 3, 4, 5, 6, 8]):
    lin = 5 + i
    c = s.cell(lin, 1, v)
    c.font, c.number_format = AZUL, RS2
    for col in COLS:
        dre = "'DRE 3 anos'!"
        c = s[f"{col}{lin}"]
        c.value = (f"={dre}{col}{R['ebit']}+{dre}{col}{R['funcs']}*12*($A{lin}-{P['pepm']})*(1-{P['imposto']})")
        c.number_format, c.font = RS, NORMAL
s.column_dimensions["A"].width = 26
for col in COLS:
    s.column_dimensions[col].width = 18

# ---------------------------------------------------------------- Por atendimento
a = wb.create_sheet("Por atendimento")
a["A1"] = "Um atendimento: acompanhante + carro (família no plano Grátis)"
a["A1"].font = TITULO
a["A2"] = "Valores puxados da aba Premissas."
a["A2"].font = NOTA
LIN = [
    ("Família paga: acompanhante", f"={P['acomp']}"),
    ("Família paga: transporte", f"={P['transp']}"),
    ("Família paga: taxa de serviço", f"={P['taxa']}"),
    ("Total pago pela família", "=SUM(B4:B6)"),
    None,
    ("Repasse ao acompanhante", f"=-B4*{P['repasse']}"),
    ("Carro ida e volta", f"=-{P['carro']}"),
    ("Taxa de pagamento", f"=-B7*{P['pgto']}"),
    ("Seguro", f"=-{P['seguro']}"),
    ("IA + WhatsApp", f"=-{P['ia_at']}"),
    ("Impostos sobre a receita própria", f"=-(B7+B9+B10)*{P['imposto']}"),
    ("Sobra para o Zelo (margem de contribuição)", "=B7+SUM(B9:B14)"),
    ("% do que a família pagou", "=IF(B7=0,0,B15/B7)"),
]
for i, item in enumerate(LIN):
    if not item:
        continue
    rot, f = item
    lin = 4 + i
    a.cell(lin, 1, rot).font = NEGRITO if lin in (7, 15) else NORMAL
    c = a.cell(lin, 2, f)
    c.number_format = PCT if lin == 16 else RS2
    c.font = NEGRITO if lin in (7, 15) else NORMAL
a.column_dimensions["A"].width = 46
a.column_dimensions["B"].width = 16

for ws in wb:
    for row in ws.iter_rows():
        for c in row:
            if c.column > 1 and isinstance(c.value, str) and not c.value.startswith("="):
                c.alignment = Alignment(wrap_text=False)
wb.save(SAIDA)
print(SAIDA)
